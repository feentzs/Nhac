package com.feentzs.nhac

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle

class LiveNotificationManager(private val context: Context) {
    private val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    private val CHANNEL_ID = "live_tracking_channel"

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Rastreio de Pedidos (Live)",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notificações em tempo real sobre o seu pedido"
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showLiveNotification(pedidoId: String, nomeProduto: String, status: String, tempoEstimado: String, stageIndex: Int) {
        val notification = buildNotification(pedidoId, nomeProduto, status, tempoEstimado, stageIndex)
        notificationManager.notify(pedidoId.hashCode(), notification)
    }

    fun updateLiveNotification(pedidoId: String, nomeProduto: String, status: String, tempoEstimado: String, stageIndex: Int) {
        val notification = buildNotification(pedidoId, nomeProduto, status, tempoEstimado, stageIndex)
        notificationManager.notify(pedidoId.hashCode(), notification)
    }

    fun cancelLiveNotification(pedidoId: String) {
        notificationManager.cancel(pedidoId.hashCode())
    }

    private fun buildNotification(pedidoId: String, nomeProduto: String, status: String, tempoEstimado: String, stageIndex: Int): Notification {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }

        val pendingIntent = PendingIntent.getActivity(
            context, pedidoId.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context)
        }

        val tempoFormatado = if (tempoEstimado.isNotEmpty() && tempoEstimado != "Entregue") " • Previsão: $tempoEstimado" else ""

        builder.setSmallIcon(android.R.drawable.ic_dialog_map)
            .setContentTitle(status)
            .setContentText("$nomeProduto$tempoFormatado")
            .setOnlyAlertOnce(true)
            .setOngoing(stageIndex < 4) // 4 is Delivered
            .setContentIntent(pendingIntent)
            .setWhen(System.currentTimeMillis())
            .setShowWhen(true)

        // Action Button: Ver Pedido
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val actionIcon = Icon.createWithResource(context, android.R.drawable.ic_menu_view)
            val action = Notification.Action.Builder(actionIcon, "Ver Pedido", pendingIntent).build()
            builder.addAction(action)
        }

        if (Build.VERSION.SDK_INT >= 35) { // Assuming 35 or 36 has these features
            val extras = Bundle()
            extras.putBoolean("android.requestPromotedOngoing", true)
            builder.setExtras(extras)
            builder.setCategory(Notification.CATEGORY_PROGRESS)

            try {
                // Try setShortCriticalText (Max ~7 chars recommended for the chip)
                val shortStatus = when (stageIndex) {
                    0 -> "Pendente"
                    1 -> "Pago"
                    2 -> "Preparo"
                    3 -> "Na rua"
                    4 -> "Chegou"
                    else -> status.take(7)
                }
                val method = Notification.Builder::class.java.getMethod("setShortCriticalText", CharSequence::class.java)
                method.invoke(builder, shortStatus)
            } catch (e: Exception) {
                // Ignore if not available in this API level
            }

            try {
                // Try ProgressStyle
                val segments = mutableListOf<Notification.ProgressStyle.Segment>()
                for (i in 0 until 5) {
                    val color = when {
                        i < stageIndex -> Color.GREEN // Completed
                        i == stageIndex -> Color.BLUE // Current
                        else -> Color.GRAY // Pending
                    }
                    val segment = Notification.ProgressStyle.Segment(100).setColor(color)
                    segments.add(segment)
                }

                val progressStyle = Notification.ProgressStyle()
                    .setProgress(stageIndex * 25)
                    .setProgressSegments(segments)
                    .setStyledByProgress(true)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val trackerIcon = Icon.createWithResource(context, android.R.drawable.ic_menu_directions)
                    progressStyle.javaClass.getMethod("setProgressTrackerIcon", Icon::class.java).invoke(progressStyle, trackerIcon)
                }

                builder.setStyle(progressStyle)
            } catch (e: Exception) {
                // Fallback progress
                builder.setProgress(4, stageIndex, false)
            }
        } else {
            builder.setProgress(4, stageIndex, false)
        }

        return builder.build()
    }
}
