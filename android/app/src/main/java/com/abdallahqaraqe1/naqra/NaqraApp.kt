package com.abdallahqaraqe1.naqra

import android.app.Application
import com.abdallahqaraqe1.naqra.core.L10n
import com.abdallahqaraqe1.naqra.work.Inputs
import kotlin.concurrent.thread

class NaqraApp : Application() {
    companion object {
        /** For tools that reach the clipboard or their bundled data; set before anything else runs. */
        lateinit var instance: NaqraApp
            private set
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        L10n.load(this)
        thread(name = "cleanup", isDaemon = true) { Inputs.cleanUp(this) }
    }
}
