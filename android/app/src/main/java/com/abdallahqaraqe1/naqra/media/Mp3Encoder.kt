package com.abdallahqaraqe1.naqra.media

/** LAME, built from source into libnaqra-mp3.so (see android/app/src/main/cpp). */
object Mp3Encoder {
    init {
        System.loadLibrary("naqra-mp3")
    }

    @JvmStatic external fun open(rate: Int, channels: Int, quality: Int, kbps: Int): Long
    @JvmStatic external fun encode(handle: Long, pcm: ShortArray, frames: Int, channels: Int, out: ByteArray): Int
    @JvmStatic external fun flush(handle: Long, out: ByteArray): Int
    @JvmStatic external fun header(handle: Long, out: ByteArray): Int
    @JvmStatic external fun close(handle: Long)
}
