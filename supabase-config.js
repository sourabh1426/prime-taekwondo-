/* Paste the Supabase Project URL and publishable key here. Never put a service_role key in this file. */
window.PRIME_SUPABASE_SETTINGS = {
  url: "https://xwbbiyoljzfwmrgwkrwb.supabase.co",
  publishableKey: "sb_publishable_B74Ba1iT8obkEzq_O7aiAQ_c0g9b4Qv"
};

window.createPrimeSupabaseClient = function (scope = 'default') {
  const settings = window.PRIME_SUPABASE_SETTINGS || {};
  if (!window.supabase || !settings.url || !settings.publishableKey ||
      settings.url.includes("YOUR_PROJECT_REF") || settings.publishableKey.includes("YOUR_")) {
    return null;
  }
  if (scope === 'member') {
    if (!window.__primeSupabaseMemberClient) {
      window.__primeSupabaseMemberClient = window.supabase.createClient(settings.url, settings.publishableKey, {
        auth: { storageKey: 'prime-taekwondo-member-auth' }
      });
    }
    return window.__primeSupabaseMemberClient;
  }
  if (!window.__primeSupabaseClient) {
    window.__primeSupabaseClient = window.supabase.createClient(settings.url, settings.publishableKey);
  }
  return window.__primeSupabaseClient;
};
