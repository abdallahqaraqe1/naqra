package com.abdallahqaraqe1.naqra.ops

import com.abdallahqaraqe1.naqra.core.NaqraException
import com.abdallahqaraqe1.naqra.core.OperationWork

/** The actions wheel. Each one needs the screen, so the wheel performs them itself; these only name them. */
object FileActions {
    private val app: OperationWork = { _, _ -> throw NaqraException("This action needs the app.") }
    val Share = app
    val OpenWith = app
    val Copy = app
    val SaveTo = app
    val Print = app
    val Details = app
}
