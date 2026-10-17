import from frontend { TripMateLanding }
import from services.tripmate { generate_tripmate_reply }
import ".styles.global.css";

# Single-page landing app.
def:pub app() -> JsxElement {
    return <TripMateLanding />;
}
