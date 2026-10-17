import from frontend { TripMateLanding }
import from services.tripmate { generate_tripmate_reply, suggest_budget_recovery }
import ".styles.global.css";

# Single-page landing app.
def:pub app() -> JsxElement {
    return <TripMateLanding />;
}
