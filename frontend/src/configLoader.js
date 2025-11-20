let runtimeConfig = null;

export async function loadRuntimeConfig() {
  if (!runtimeConfig) {
    const res = await fetch("/config/config.json");
    try {
      runtimeConfig = await res.json();
    } catch (e) {
      console.log(`Error while loading config: ${e}`);
    }
  }
  return runtimeConfig;
}
