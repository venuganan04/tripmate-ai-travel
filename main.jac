import from frontend { TripMateLanding }
import ".styles.global.css";

# Single-page landing app.
def:pub app() -> JsxElement {
    return <TripMateLanding />;
}
