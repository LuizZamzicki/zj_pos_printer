package com.example.zj_pos_printer

import android.app.Activity
import android.content.Context
import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import android.os.Message

import com.zj.usbsdk.UsbController
import com.zj.usbsdk.PrintPic

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * ZjPosPrinterPlugin
 * Implementation using ActivityAware because the ZJ SDK requires an Activity context 
 * to handle USB permissions and UI-related tasks.
 */
class ZjPosPrinterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
  private var activity: Activity? = null
  private var usbCtrl: UsbController? = null
  private var device: UsbDevice? = null

  private val mHandler = object : Handler(Looper.getMainLooper()) {
    override fun handleMessage(msg: Message) {
      when (msg.what) {
        UsbController.USB_CONNECTED -> {
            // Successfully connected via USB
        }
      }
    }
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "zj_pos_printer")
    channel.setMethodCallHandler(this)
  }

  // ActivityAware implementation to capture the current Activity context
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activity?.let {
        // SDK initialization requires an Activity instance
        usbCtrl = UsbController(it, mHandler)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "connect" -> {
        connectPrinter()
        result.success(true)
      }
      "printText" -> {
        val text = call.argument<String>("text") ?: ""
        val isBold = call.argument<Boolean>("bold") ?: false
        val size = call.argument<Int>("size") ?: 0 
        val align = call.argument<Int>("align") ?: 0 
        val charsetName = call.argument<String>("charsetName") ?: "CP860" 
        val codePageByte = call.argument<Int>("codePageByte") ?: 0x0D

        val ctrl = usbCtrl
        val dev = device

        if (ctrl != null && dev != null) {
            // 1. ESC @ - Initialize/Reset printer to default settings
            ctrl.sendByte(byteArrayOf(0x1B, 0x40), dev)

            // 2. ESC t - Select character code table (0x0D = CP860 Portuguese)
            // It is vital to set the code page BEFORE sending styled text
            ctrl.sendByte(byteArrayOf(0x1B, 0x74, codePageByte.toByte()), dev)

            // 3. ESC a - Set alignment (0:Left, 1:Center, 2:Right)
            ctrl.sendByte(byteArrayOf(0x1B, 0x61, align.toByte()), dev)

            // 4. Master Select (ESC !) or Specific Styles
            // We use ESC ! 0x30 for double height/width if size is requested
            if (size > 0) {
                ctrl.sendByte(byteArrayOf(0x1B, 0x21, 0x30.toByte()), dev)
            } else {
                ctrl.sendByte(byteArrayOf(0x1B, 0x21, 0x00.toByte()), dev)
            }

            // 5. ESC E - Set emphasized (Bold) mode
            ctrl.sendByte(byteArrayOf(0x1B, 0x45, if (isBold) 0x01 else 0x00), dev)

            // 6. Send the encoded string
            ctrl.sendMsg(text, charsetName, dev)
            
            // 7. Reset to default to avoid affecting subsequent print jobs
            ctrl.sendByte(byteArrayOf(0x1B, 0x40), dev)

            result.success(true)
        } else {
            result.error("PRINTER_NOT_FOUND", "Printer not connected or permission denied", null)
        }
      } 
      else -> result.notImplemented()
    } 
  }

  private fun connectPrinter() {
    // Standard Vendor IDs and Product IDs for common ZJ thermal printers
    val devices = arrayOf(
      intArrayOf(0x1CBE, 0x0003),
      intArrayOf(0x1CB0, 0x0003),
      intArrayOf(0x0483, 0x5740),
      intArrayOf(0x0493, 0x8760),
      intArrayOf(0x0416, 0x5011),
      intArrayOf(0x0416, 0xAABB)
    )

    val ctrl = usbCtrl ?: return

    for (info in devices) {
      device = ctrl.getDev(info[0], info[1])
      if (device != null) break
    }

    device?.let { dev ->
      // Requesting runtime USB permission from the user
      if (!ctrl.isHasPermission(dev)) {
        ctrl.getPermission(dev)
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    usbCtrl?.close()
    usbCtrl = null
  }
}