package kuro;

import android.app.Activity;
import android.app.WallpaperManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;

public class Kuro extends Activity {
    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        try {
            Bitmap bm = Bitmap.createBitmap(480, 800, Bitmap.Config.ARGB_8888);
            bm.eraseColor(Color.BLACK);
            WallpaperManager wm = WallpaperManager.getInstance(this);
            wm.setBitmap(bm, null, true, WallpaperManager.FLAG_SYSTEM);
            wm.setBitmap(bm, null, true, WallpaperManager.FLAG_LOCK);
            Log.i("Kuro", "OK fondo negro en inicio y bloqueo");
        } catch (Exception e) {
            Log.e("Kuro", "FALLO", e);
        }
        finish();
    }
}
