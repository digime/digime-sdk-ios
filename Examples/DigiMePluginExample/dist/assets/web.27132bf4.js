import { W as WebPlugin } from "./index.951a9c0e.js";
class DigiPluginWeb extends WebPlugin {
  async echo(options) {
    console.log("ECHO", options);
    return options;
  }
}
export { DigiPluginWeb };
