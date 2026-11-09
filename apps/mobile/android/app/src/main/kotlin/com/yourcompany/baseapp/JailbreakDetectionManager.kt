package com.yourcompany.baseapp

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.BufferedReader
import java.io.InputStreamReader

class JailbreakDetectionManager(private val context: Context) {
    fun isRooted(): Boolean {
        return checkForSuBinary() ||
                checkBuildTags() ||
                checkForSuspiciousPackages() ||
                checkForSuspiciousFiles() ||
                checkForSystemPartitionModification()
    }

    private fun checkForSuBinary(): Boolean {
        val suPaths = arrayOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/data/local/xbin/su",
            "/data/local/tmp/su",
            "/data/local/su",
            "/system/app/SuperSU.apk",
            "/system/app/SuperUser.apk"
        )
        for (path in suPaths) {
            if (java.io.File(path).exists()) return true
        }
        return checkWhichCommand()
    }

    private fun checkWhichCommand(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("which su")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val line = reader.readLine()
            reader.close()
            line != null && line.isNotEmpty()
        } catch (e: Exception) {
            false
        }
    }

    private fun checkBuildTags(): Boolean {
        return Build.TAGS != null && Build.TAGS.contains("test-keys")
    }

    private fun checkForSuspiciousPackages(): Boolean {
        val suspiciousPackages = arrayOf(
            "com.topjohnwu.magisk",
            "io.magisk.manager",
            "eu.chainfire.supersu",
            "com.koushikdutta.superuser",
            "com.thirdparty.superuser",
            "com.yellowes.su",
            "com.noshufou.android.su",
            "com.m0narx.su",
            "com.fs0und.xposed",
            "de.robv.android.xposed.installer",
            "com.saurik.substrate",
            "com.devadvance.rootcloak",
            "com.devadvance.rootcloakplus",
            "de.boehmer.secureshell"
        )
        val packageManager = context.packageManager
        for (packageName in suspiciousPackages) {
            try {
                packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                return true
            } catch (e: PackageManager.NameNotFoundException) {
                // not installed — continue
            }
        }
        return false
    }

    private fun checkForSuspiciousFiles(): Boolean {
        val suspiciousFiles = arrayOf(
            "/system/bin/rootcloaker",
            "/system/bin/rootcloaker.jar",
            "/system/lib/libjni_rootcloaker.so",
            "/system/app/Superuser.apk",
            "/system/app/SuperSU.apk",
            "/system/xbin/daemonsu",
            "/system/etc/init.d/99SuperSUDaemon",
            "/dev/com.android.settings",
            "/system/.supersu",
            "/cache/.supersu",
            "/data/.supersu",
            "/.supersu"
        )
        for (file in suspiciousFiles) {
            if (java.io.File(file).exists()) return true
        }
        return false
    }

    private fun checkForSystemPartitionModification(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("mount")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String?
            var foundRW = false
            while (reader.readLine().also { line = it } != null) {
                if (line != null && line!!.contains("/system") && line!!.contains("rw")) {
                    foundRW = true
                    break
                }
            }
            reader.close()
            foundRW
        } catch (e: Exception) {
            false
        }
    }
}
