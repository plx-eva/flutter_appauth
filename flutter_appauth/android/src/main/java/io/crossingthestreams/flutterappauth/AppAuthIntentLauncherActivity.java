package io.crossingthestreams.flutterappauth;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

public class AppAuthIntentLauncherActivity extends Activity {
  static class IntentExtraKey {
    static String INTENT = "intent";
    static String REQUEST_CODE = "requestCode";
  }

  @Nullable private static AppAuthIntentLauncherActivity currentInstance;

  /**
   * Finishes the launcher activity currently presenting the external user agent (if any),
   * which in turn dismisses the browser/Custom Tab it started.
   */
  static void dismiss() {
    AppAuthIntentLauncherActivity instance = currentInstance;
    if (instance != null) {
      instance.finish();
    }
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    currentInstance = this;

    Intent intent = getIntent().getParcelableExtra(IntentExtraKey.INTENT);
    if (intent != null) {
      int requestCode = getIntent().getIntExtra(IntentExtraKey.REQUEST_CODE, 0);
      startActivityForResult(intent, requestCode);
    } else {
      finish();
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    if (currentInstance == this) {
      currentInstance = null;
    }
  }

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);

    finish();

    FlutterAppauthPlugin flutterAppauthPlugin = FlutterAppauthPlugin.getInstance();
    if (flutterAppauthPlugin != null) {
      flutterAppauthPlugin.onActivityResult(requestCode, resultCode, data);
    }
  }
}