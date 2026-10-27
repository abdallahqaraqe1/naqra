package com.abdallahqaraqe1.naqra.ops

import android.content.ClipData
import android.content.ClipboardManager
import android.os.Handler
import android.os.Looper
import com.abdallahqaraqe1.naqra.NaqraApp

object Clipboard {
    fun copyText(text: String) {
        val app = NaqraApp.instance
        Handler(Looper.getMainLooper()).post {
            app.getSystemService(ClipboardManager::class.java).setPrimaryClip(ClipData.newPlainText("Naqra", text))
        }
    }
}
