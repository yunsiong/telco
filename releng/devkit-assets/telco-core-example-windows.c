/*
 * To build, set up your Release configuration like this:
 *
 * [Runtime Library]
 * Multi-threaded (/MT)
 *
 * Visit https://telco.re to learn more about Telco.
 */

#include "telco-core.h"

#include <stdlib.h>
#include <string.h>

static void on_detached (TelcoSession * session, TelcoSessionDetachReason reason, TelcoCrash * crash, gpointer user_data);
static void on_message (TelcoScript * script, const gchar * message, GBytes * data, gpointer user_data);
static void on_signal (int signo);
static gboolean stop (gpointer user_data);

static GMainLoop * loop = NULL;

int
main (int argc,
      char * argv[])
{
  guint target_pid;
  TelcoDeviceManager * manager;
  GError * error = NULL;
  TelcoDeviceList * devices;
  gint num_devices, i;
  TelcoDevice * local_device;
  TelcoSession * session;

  telco_init ();

  if (argc != 2 || (target_pid = atoi (argv[1])) == 0)
  {
    g_printerr ("Usage: %s <pid>\n", argv[0]);
    return 1;
  }

  loop = g_main_loop_new (NULL, TRUE);

  signal (SIGINT, on_signal);
  signal (SIGTERM, on_signal);

  manager = telco_device_manager_new ();

  devices = telco_device_manager_enumerate_devices_sync (manager, NULL, &error);
  g_assert (error == NULL);

  local_device = NULL;
  num_devices = telco_device_list_size (devices);
  for (i = 0; i != num_devices; i++)
  {
    TelcoDevice * device = telco_device_list_get (devices, i);

    g_print ("[*] Found device: \"%s\"\n", telco_device_get_name (device));

    if (telco_device_get_dtype (device) == TELCO_DEVICE_TYPE_LOCAL)
      local_device = g_object_ref (device);

    g_object_unref (device);
  }
  g_assert (local_device != NULL);

  telco_unref (devices);
  devices = NULL;

  session = telco_device_attach_sync (local_device, target_pid, NULL, NULL, &error);
  if (error == NULL)
  {
    TelcoScript * script;
    TelcoScriptOptions * options;

    g_signal_connect (session, "detached", G_CALLBACK (on_detached), NULL);
    if (telco_session_is_detached (session))
      goto session_detached_prematurely;

    g_print ("[*] Attached\n");

    options = telco_script_options_new ();
    telco_script_options_set_name (options, "example");
    telco_script_options_set_runtime (options, TELCO_SCRIPT_RUNTIME_QJS);

    script = telco_session_create_script_sync (session,
        "Interceptor.attach(Module.getExportByName('kernel32.dll', 'CreateFileW'), {\n"
        "  onEnter(args) {\n"
        "    console.log(`[*] CreateFileW(\"${args[0].readUtf16String()}\")`);\n"
        "  }\n"
        "});\n"
        "Interceptor.attach(Module.getExportByName('kernel32.dll', 'CloseHandle'), {\n"
        "  onEnter(args) {\n"
        "    console.log(`[*] CloseHandle(${args[0]})`);\n"
        "  }\n"
        "});",
        options, NULL, &error);
    g_assert (error == NULL);

    g_clear_object (&options);

    g_signal_connect (script, "message", G_CALLBACK (on_message), NULL);

    telco_script_load_sync (script, NULL, &error);
    g_assert (error == NULL);

    g_print ("[*] Script loaded\n");

    if (g_main_loop_is_running (loop))
      g_main_loop_run (loop);

    g_print ("[*] Stopped\n");

    telco_script_unload_sync (script, NULL, NULL);
    telco_unref (script);
    g_print ("[*] Unloaded\n");

    telco_session_detach_sync (session, NULL, NULL);
session_detached_prematurely:
    telco_unref (session);
    g_print ("[*] Detached\n");
  }
  else
  {
    g_printerr ("Failed to attach: %s\n", error->message);
    g_error_free (error);
  }

  telco_unref (local_device);

  telco_device_manager_close_sync (manager, NULL, NULL);
  telco_unref (manager);
  g_print ("[*] Closed\n");

  g_main_loop_unref (loop);

  return 0;
}

static void
on_detached (TelcoSession * session,
             TelcoSessionDetachReason reason,
             TelcoCrash * crash,
             gpointer user_data)
{
  gchar * reason_str;

  reason_str = g_enum_to_string (TELCO_TYPE_SESSION_DETACH_REASON, reason);
  g_print ("on_detached: reason=%s crash=%p\n", reason_str, crash);
  g_free (reason_str);

  g_idle_add (stop, NULL);
}

static void
on_message (TelcoScript * script,
            const gchar * message,
            GBytes * data,
            gpointer user_data)
{
  JsonParser * parser;
  JsonObject * root;
  const gchar * type;

  parser = json_parser_new ();
  json_parser_load_from_data (parser, message, -1, NULL);
  root = json_node_get_object (json_parser_get_root (parser));

  type = json_object_get_string_member (root, "type");
  if (strcmp (type, "log") == 0)
  {
    const gchar * log_message;

    log_message = json_object_get_string_member (root, "payload");
    g_print ("%s\n", log_message);
  }
  else
  {
    g_print ("on_message: %s\n", message);
  }

  g_object_unref (parser);
}

static void
on_signal (int signo)
{
  g_idle_add (stop, NULL);
}

static gboolean
stop (gpointer user_data)
{
  g_main_loop_quit (loop);

  return FALSE;
}
