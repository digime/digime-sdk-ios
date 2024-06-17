import { DigiPlugin } from 'digi-plugin';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    DigiPlugin.echo({ value: inputValue })
}
