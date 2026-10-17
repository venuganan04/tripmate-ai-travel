import from .components.ui.button { Button }
import from .components.ui.card { Card, CardContent }
import from .components.ui.input { Input }
sv import from .services.tripmate { generate_tripmate_reply }

# Sri Lanka travel notes used by TripMate's offline companion.
glob places: list[dict] = [
    {"name": "Galle", "tag": "COASTAL CHARM", "desc": "Wander the old fort, linger over ocean views, and find your own quiet corner.", "image": "photo-1533105079780-92b9be482077", "tone": "from-[#123d3d]"},
    {"name": "Ella", "tag": "HIGHLAND ESCAPE", "desc": "Tea-covered hills, cloud forests, and a train ride worth slowing down for.", "image": "photo-1500530855697-b586d89ba3ee", "tone": "from-[#294d3e]"},
    {"name": "Kandy", "tag": "CULTURE & HERITAGE", "desc": "A lakeside city shaped by sacred history, gardens, and living traditions.", "image": "photo-1518005020951-eccb494ad742", "tone": "from-[#59472f]"},
    {"name": "Sigiriya", "tag": "ANCIENT WONDER", "desc": "Climb above the jungle canopy to a remarkable chapter of island history.", "image": "photo-1516026672322-bc52d61a55d5", "tone": "from-[#445329]"},
    {"name": "Mirissa", "tag": "SOUTHERN SHORES", "desc": "Golden sand, warm-water swims, and long lunches by the sea.", "image": "photo-1507525428034-b723cf961d3e", "tone": "from-[#315262]"},
    {"name": "Nuwara Eliya", "tag": "TEA COUNTRY", "desc": "Cool air, rolling tea estates, and a gentler pace in the highlands.", "image": "photo-1448375240586-882707db888b", "tone": "from-[#3e5941]"}
];

cl def:pub TripMateLanding() -> JsxElement {
    has destination: str = "";
    has start_date: str = "";
    has end_date: str = "";
    has travelers: str = "2";
    has budget: str = "";
    has interests: str = "Nature";
    has trips: list[dict] = [];
    has itinerary: list[str] = [];
    has notice: str = "";
    has chat_open: bool = False;
    has chat_input: str = "";
    has chat_loading: bool = False;
    has chat_error: str = "";
    has chat_lines: list[dict] = [{"who": "TripMate", "text": "Ayubowan! Ask me about Sri Lanka travel. Gemini answers when securely configured on the server; replies use only the trip and expense context provided in this session."}];

    def on_destination(e: ChangeEvent) { destination = e.target.value; }
    def on_start(e: ChangeEvent) { start_date = e.target.value; }
    def on_end(e: ChangeEvent) { end_date = e.target.value; }
    def on_travelers(e: ChangeEvent) { travelers = e.target.value; }
    def on_budget(e: ChangeEvent) { budget = e.target.value; }
    def on_interests(e: ChangeEvent) { interests = e.target.value; }
    def on_chat_input(e: ChangeEvent) { chat_input = e.target.value; }

    def select_place(name: str) {
        destination = name;
        notice = name + " selected. Add dates and interests to shape your trip.";
        document.getElementById("planner")?.scrollIntoView({"behavior": "smooth"});
    }

    def make_itinerary(e: FormEvent) {
        e.preventDefault();
        if not destination.strip() or not start_date or not end_date or not budget.strip() {
            notice = "Add a destination, both dates, and a budget to create your itinerary.";
            return;
        }
        if end_date < start_date {
            notice = "Your return date must be on or after your start date.";
            return;
        }
        plan: list[str] = [
            "Day 1 · Arrive in " + destination + ", settle in, and explore at an easy pace.",
            "Day 2 · Spend the morning on " + interests.lower() + " and leave the afternoon open for a local café.",
            "Day 3 · Take a short local excursion, try a Sri Lankan meal, and enjoy a relaxed final evening."
        ];
        itinerary = plan;
        trips = [{"destination": destination, "start": start_date, "end": end_date, "travelers": travelers, "budget": budget, "interests": interests}] + trips;
        notice = "Your sample 3-day itinerary is ready and saved for this session.";
    }

    def remove_trip(index: int) {
        trips = [trip for (i, trip) in enumerate(trips) if i != index];
        notice = "Trip removed from this session.";
    }

    def send_chat(e: FormEvent) {
        e.preventDefault();
        send_chat_form();
    }

    async def retry_chat(e: MouseEvent) {
        await send_chat_form();
    }

    async def send_chat_form() {
        if not chat_input.strip() or chat_loading { return; }
        chat_loading = True;
        chat_error = "";
        context = "Current session trip: " + destination + "; dates: " + start_date + " to " + end_date + "; travelers: " + travelers + "; interests: " + interests + "; planned budget LKR: " + budget + ". Current itinerary: " + str(itinerary) + ". Session trips: " + str(trips) + ". Recorded expenses: none; this version has no expense tracker.";
        try {
            result = await generate_tripmate_reply(chat_input.strip(), context);
            if result["ok"] { chat_lines = chat_lines + [{"who": "You", "text": chat_input.strip()}, {"who": "TripMate · Gemini", "text": result["reply"] as str}]; chat_input = ""; }
            else { chat_error = result["message"] as str; }
        } except Exception { chat_error = "TripMate couldn't reach Gemini. Your trip is unchanged. Please retry."; }
        chat_loading = False;
    }

    def new_conversation(e: MouseEvent) {
        chat_lines = [{"who": "TripMate", "text": "New conversation started. Gemini uses only the current trip details and this session's chat."}];
        chat_error = "";
        chat_input = "";
    }

    return <div className="min-h-screen bg-[#f6f5f0] text-[#173c3a]">
        <nav className="sticky top-0 z-30 border-b border-[#173c3a]/10 bg-[#fbfaf7]/95 backdrop-blur">
            <div className="mx-auto flex h-[72px] max-w-7xl items-center justify-between px-5 md:px-10">
                <a href="#home" className="flex items-center gap-2.5" aria-label="TripMate home">
                    <span className="flex size-9 items-center justify-center rounded-xl bg-[#0B3D46] text-lg font-bold text-white">T</span>
                    <span className="text-xl font-bold tracking-tight">tripmate<span className="text-[#20BFA9]">.</span></span>
                </a>
                <div className="hidden items-center gap-8 text-sm font-medium text-[#315250] md:flex">
                    <a href="#destinations" className="transition-colors hover:text-[#119c8c]">Destinations</a>
                    <a href="#planner" className="transition-colors hover:text-[#119c8c]">Trip planner</a>
                    <a href="#my-trips" className="transition-colors hover:text-[#119c8c]">My trips</a>
                </div>
                <a href="#planner" className="rounded-full bg-[#0B3D46] px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-[#15545b]">Plan my trip <span aria-hidden="true">↗</span></a>
            </div>
        </nav>

        <main id="home">
            <section className="relative isolate overflow-hidden bg-[#0B3D46] text-white">
                <div className="absolute inset-0 -z-10 bg-cover bg-center opacity-55" style={{"backgroundImage": "linear-gradient(90deg, rgba(6,39,43,.94) 0%, rgba(6,39,43,.64) 48%, rgba(6,39,43,.12) 100%), url(https://images.unsplash.com/photo-1588598198321-9735fe7f9a5b?auto=format&fit=crop&w=2000&q=85)"}}></div>
                <div className="mx-auto grid min-h-[610px] max-w-7xl items-center gap-12 px-5 py-16 md:px-10 lg:grid-cols-[1.05fr_.95fr] lg:py-24">
                    <div className="max-w-2xl animate-in fade-in slide-in-from-bottom-2 duration-500">
                        <p className="mb-6 inline-flex items-center gap-2 rounded-full border border-white/25 bg-white/10 px-4 py-2 text-xs font-semibold tracking-[.16em] text-[#b6f1e6]">A LITTLE ISLAND, A LOT TO DISCOVER</p>
                        <h1 className="text-balance text-5xl font-semibold leading-[1.06] tracking-tight md:text-7xl">Discover Sri Lanka <span className="text-[#65d8c5]">your way.</span></h1>
                        <p className="mt-6 max-w-xl text-lg leading-8 text-white/80">Plan unforgettable journeys, explore hidden gems, and travel with a smart companion by your side.</p>
                        <form onSubmit={make_itinerary} className="mt-9 flex max-w-xl flex-col gap-3 rounded-2xl bg-white p-3 shadow-2xl sm:flex-row">
                            <label className="sr-only" htmlFor="hero-destination">Where would you like to go?</label>
                            <Input id="hero-destination" value={destination} onChange={on_destination} placeholder="Where would you like to go?" className="h-12 border-0 bg-transparent text-[#173c3a] shadow-none focus-visible:ring-0" />
                            <Button type="submit" className="h-12 shrink-0 rounded-xl bg-[#20BFA9] px-6 font-semibold text-[#073b3a] hover:bg-[#62d7c7]">Start planning <span aria-hidden="true">→</span></Button>
                        </form>
                        <p className="mt-3 text-sm text-white/65">Add travel dates and budget below to build your sample itinerary.</p>
                        <div className="mt-8 flex flex-wrap gap-3">
                            <a href="#destinations" className="rounded-full border border-white/45 px-5 py-2.5 text-sm font-semibold text-white transition-colors hover:bg-white/10">Explore destinations</a>
                            <a href="#planner" className="rounded-full px-5 py-2.5 text-sm font-semibold text-white/85 hover:text-white">Build a trip <span aria-hidden="true">↓</span></a>
                        </div>
                    </div>
                    <div className="hidden lg:block">
                        <div className="ml-auto max-w-sm rotate-2 rounded-[28px] border border-white/30 bg-white/10 p-3 shadow-2xl backdrop-blur-md">
                            <img className="h-[350px] w-full rounded-[20px] object-cover" src="https://images.unsplash.com/photo-1588598198321-9735fe7f9a5b?auto=format&fit=crop&w=900&q=85" alt="Lush green Sri Lankan landscape" />
                            <div className="flex items-center justify-between px-3 py-4"><div><p className="text-xs tracking-widest text-[#a8e9dc]">YOUR NEXT STORY</p><p className="mt-1 text-lg font-semibold">The island is calling</p></div><span className="flex size-11 items-center justify-center rounded-full bg-[#20BFA9] text-xl text-[#073b3a]">↗</span></div>
                        </div>
                    </div>
                </div>
                <div className="absolute bottom-0 left-0 right-0 h-10 rounded-t-[50%] bg-[#f6f5f0]"></div>
            </section>

            <section id="destinations" className="mx-auto max-w-7xl px-5 py-16 md:px-10 md:py-24">
                <div className="mb-9 flex flex-wrap items-end justify-between gap-5">
                    <div><p className="text-xs font-bold tracking-[.18em] text-[#0b9d8e]">THE ISLAND, YOURS TO FIND</p><h2 className="mt-3 text-3xl font-semibold tracking-tight md:text-4xl">Places that stay with you</h2></div>
                    <p className="max-w-sm text-sm leading-6 text-[#607572]">From misty mountains to the southern shore, start with the feeling you want to find.</p>
                </div>
                <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
                    {for (i, place) in enumerate(places) {
                        <Card key={place["name"]} className="group overflow-hidden rounded-[22px] border-[#e6e5dc] bg-white shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-lg">
                            <div className="relative h-56 overflow-hidden bg-[#d8e5df]"><img src={"https://images.unsplash.com/" + (place["image"] as str) + "?auto=format&fit=crop&w=900&q=80"} alt={(place["name"] as str) + ", Sri Lanka"} className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105" /><span className="absolute left-4 top-4 rounded-full bg-white/90 px-3 py-1.5 text-[10px] font-bold tracking-[.14em] text-[#315250]">{place["tag"]}</span></div>
                            <CardContent className="p-5"><div className="flex items-start justify-between gap-3"><h3 className="text-xl font-semibold">{place["name"]}</h3><span className="text-xl text-[#20BFA9]">↗</span></div><p className="mt-2 min-h-12 text-sm leading-6 text-[#607572]">{place["desc"]}</p><button onClick={lambda { select_place(place["name"]); }} className="mt-4 text-sm font-semibold text-[#087f74] transition-colors hover:text-[#0B3D46]">Choose {place["name"]} <span aria-hidden="true">→</span></button></CardContent>
                        </Card>
                    }}
                </div>
            </section>

            <section id="planner" className="bg-[#e9f1ec] px-5 py-16 md:px-10 md:py-24">
                <div className="mx-auto grid max-w-7xl gap-10 lg:grid-cols-[.82fr_1.18fr]">
                    <div className="flex flex-col justify-center"><p className="text-xs font-bold tracking-[.18em] text-[#087f74]">A GOOD PLACE TO BEGIN</p><h2 className="mt-3 text-3xl font-semibold tracking-tight md:text-4xl">Your island days, thoughtfully planned.</h2><p className="mt-4 max-w-lg leading-7 text-[#607572]">Share a few details and TripMate will sketch a simple locally generated itinerary. No account or AI service needed.</p><div className="mt-7 flex items-center gap-3 rounded-2xl border border-[#cfddd5] bg-white/70 p-4"><span className="flex size-10 items-center justify-center rounded-xl bg-[#20BFA9]/15 text-lg text-[#087f74]">i</span><p className="text-sm leading-6 text-[#607572]">Itineraries are sample suggestions. Confirm transport, opening times, prices, and local conditions before you go.</p></div></div>
                    <Card className="rounded-[26px] border-white bg-white shadow-lg">
                        <CardContent className="p-5 sm:p-8">
                            <form onSubmit={make_itinerary} className="flex flex-col gap-5">
                                <div className="grid gap-4 sm:grid-cols-2"><label className="flex flex-col gap-2 text-sm font-semibold">Destination<Input value={destination} onChange={on_destination} placeholder="e.g. Ella and the south coast" className="h-11 rounded-xl" /></label><label className="flex flex-col gap-2 text-sm font-semibold">Travel interests<select value={interests} onChange={on_interests} className="h-11 rounded-xl border border-input bg-background px-3 text-sm font-normal"><option>Nature</option><option>Beaches</option><option>Culture</option><option>Adventure</option><option>Wildlife</option><option>Food</option></select></label></div>
                                <div className="grid gap-4 sm:grid-cols-2"><label className="flex flex-col gap-2 text-sm font-semibold">Start date<Input type="date" value={start_date} onChange={on_start} className="h-11 rounded-xl" /></label><label className="flex flex-col gap-2 text-sm font-semibold">End date<Input type="date" value={end_date} onChange={on_end} className="h-11 rounded-xl" /></label></div>
                                <div className="grid gap-4 sm:grid-cols-2"><label className="flex flex-col gap-2 text-sm font-semibold">Travelers<Input type="number" min="1" max="20" value={travelers} onChange={on_travelers} className="h-11 rounded-xl" /></label><label className="flex flex-col gap-2 text-sm font-semibold">Budget (LKR)<Input type="number" min="1" value={budget} onChange={on_budget} placeholder="e.g. 85000" className="h-11 rounded-xl" /></label></div>
                                <Button type="submit" className="h-12 rounded-xl bg-[#0B3D46] text-white hover:bg-[#15545b]">Create my sample itinerary <span aria-hidden="true">→</span></Button>
                                {notice and <p role="status" className="rounded-xl bg-[#e8f5f0] px-4 py-3 text-sm leading-6 text-[#176356]">{notice}</p>}
                            </form>
                            {if len(itinerary) > 0 {
                                <div className="mt-6 rounded-2xl border border-[#dce8e1] bg-[#f8faf7] p-5"><div className="flex flex-wrap items-center justify-between gap-2"><h3 className="text-lg font-semibold">A first look at {destination}</h3><span className="rounded-full bg-[#def4ed] px-3 py-1 text-xs font-semibold text-[#176356]">SAMPLE PLAN</span></div><ol className="mt-4 flex flex-col gap-3">{for (i, day) in enumerate(itinerary) {<li key={str(i)} className="flex gap-3 text-sm leading-6 text-[#425d57]"><span className="flex size-6 shrink-0 items-center justify-center rounded-full bg-[#20BFA9]/15 text-xs font-bold text-[#087f74]">{str(i + 1)}</span>{day}</li>}}</ol><p className="mt-4 text-xs text-[#778984]">For {travelers} traveler(s) · Budget entered: LKR {budget}. Estimate not calculated.</p></div>
                            }}</CardContent>
                    </Card>
                </div>
            </section>

            <section id="my-trips" className="mx-auto max-w-7xl px-5 py-16 md:px-10 md:py-20">
                <div className="flex flex-wrap items-end justify-between gap-4"><div><p className="text-xs font-bold tracking-[.18em] text-[#087f74]">YOUR SHORTLIST</p><h2 className="mt-3 text-3xl font-semibold tracking-tight">My trips</h2><p className="mt-2 text-sm text-[#607572]">Saved in this browser session only.</p></div><a href="#planner" className="rounded-full border border-[#0B3D46]/20 px-4 py-2 text-sm font-semibold text-[#0B3D46] transition-colors hover:bg-white">Plan another trip +</a></div>
                <div className="mt-7 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                    {if len(trips) == 0 {<div className="rounded-2xl border border-dashed border-[#b9cbc2] bg-white/60 p-8 sm:col-span-2 lg:col-span-3"><p className="font-semibold">Your next trip starts here.</p><p className="mt-1 text-sm text-[#607572]">Create an itinerary and it will appear here until this session ends.</p><a href="#planner" className="mt-4 inline-block text-sm font-semibold text-[#087f74]">Open the trip planner →</a></div>}}
                    {for (i, trip) in enumerate(trips) {<article key={str(i)} className="rounded-2xl border border-[#e4e5dc] bg-white p-5 shadow-sm"><div className="flex items-start justify-between gap-4"><div><h3 className="text-lg font-semibold">{trip["destination"]}</h3><p className="mt-1 text-sm text-[#607572]">{trip["start"]} to {trip["end"]}</p></div><button onClick={lambda { remove_trip(i); }} className="rounded-full px-3 py-1.5 text-xs font-semibold text-[#8a5145] hover:bg-[#fbefec]">Delete</button></div><p className="mt-4 text-sm text-[#607572]">{trip["travelers"]} traveler(s) · {trip["interests"]} · LKR {trip["budget"]}</p><button onClick={lambda { destination = trip["destination"]; itinerary = ["Day 1 · Arrive in " + (trip["destination"] as str) + " and get settled.", "Day 2 · Enjoy " + (trip["interests"] as str).lower() + " at a relaxed pace.", "Day 3 · Explore locally and enjoy a final island evening."]; notice = "Opened your session itinerary for " + (trip["destination"] as str) + "."; document.getElementById("planner")?.scrollIntoView({"behavior": "smooth"}); }} className="mt-4 text-sm font-semibold text-[#087f74]">Open itinerary →</button></article>}}
                </div>
            </section>

            <section className="bg-[#0B3D46] px-5 py-14 text-white md:px-10 md:py-20">
                <div className="mx-auto grid max-w-7xl items-center gap-8 md:grid-cols-[.8fr_1.2fr]"><div><p className="text-xs font-bold tracking-[.18em] text-[#73d9c9]">A LOCAL GUIDE IN YOUR POCKET</p><h2 className="mt-3 text-3xl font-semibold">Ask the island-minded companion.</h2><p className="mt-3 max-w-md text-sm leading-6 text-white/70">Get starter tips for places, food, culture, and nature. Replies come from a small predefined local guide, not a live AI.</p></div><div className="rounded-[24px] border border-white/15 bg-white/10 p-5 backdrop-blur"><div className="flex items-center gap-3 border-b border-white/15 pb-4"><span className="flex size-10 items-center justify-center rounded-full bg-[#20BFA9] font-bold text-[#073b3a]">T</span><div><p className="font-semibold">TripMate guide</p><p className="text-xs text-[#a9d8ce]">Gemini when configured · session context only</p></div><button type="button" onClick={new_conversation} className="ml-auto rounded-full border border-white/20 px-3 py-2 text-xs font-semibold text-white hover:bg-white/10">New chat</button></div><div className="flex max-h-64 flex-col gap-3 overflow-y-auto py-4">{for (i, line) in enumerate(chat_lines) {<div key={str(i)} className={"max-w-[90%] rounded-2xl px-4 py-3 text-sm leading-6 " + ("self-end bg-[#20BFA9] text-[#073b3a]" if line["who"] == "You" else "self-start bg-white/10 text-white/90")}><p className="mb-1 text-[10px] font-bold uppercase tracking-wider opacity-70">{line["who"]}</p>{line["text"]}</div>}}{chat_loading and <div role="status" className="self-start rounded-2xl bg-white/10 px-4 py-3 text-sm text-white/80">TripMate is asking Gemini…</div>}</div>{chat_error and <div role="alert" className="mb-3 rounded-xl bg-[#ffe9e4] px-4 py-3 text-sm text-[#713e32]">{chat_error}<button type="button" onClick={retry_chat} className="ml-3 font-semibold underline">Retry</button></div>}<form onSubmit={send_chat} className="flex gap-2 rounded-xl bg-white p-2"><label className="sr-only" htmlFor="chat-question">Ask a Sri Lanka travel question</label><Input id="chat-question" value={chat_input} onChange={on_chat_input} placeholder="Ask about beaches, food, wildlife…" className="h-11 border-0 text-[#173c3a] shadow-none focus-visible:ring-0" /><Button type="submit" className="h-11 rounded-lg bg-[#20BFA9] px-4 font-semibold text-[#073b3a] hover:bg-[#70dfce]" disabled={chat_loading or not chat_input.strip()}>{"Thinking…" if chat_loading else "Send"}</Button></form></div></div>
            </section>
        </main>

        <footer className="bg-[#082f36] px-5 py-8 text-white md:px-10"><div className="mx-auto flex max-w-7xl flex-col justify-between gap-6 sm:flex-row sm:items-center"><div><p className="text-xl font-bold">tripmate<span className="text-[#20BFA9]">.</span></p><p className="mt-1 text-sm text-white/65">Go Beyond. We've Got You.</p></div><div className="flex flex-wrap gap-5 text-sm text-white/75"><a href="#destinations" className="hover:text-white">Destinations</a><a href="#planner" className="hover:text-white">Trip planner</a><a href="#my-trips" className="hover:text-white">My trips</a></div><p className="text-sm text-white/55">Your island story starts here.</p></div></footer>

        <button onClick={lambda { chat_open = not chat_open; document.getElementById("trip-chat")?.scrollIntoView({"behavior": "smooth"}); }} aria-label="Open TripMate travel chat" className="fixed bottom-5 right-5 z-40 flex items-center gap-2 rounded-full bg-[#20BFA9] px-5 py-3 font-semibold text-[#073b3a] shadow-xl transition-transform hover:scale-105"><span aria-hidden="true">✦</span>{"Ask TripMate"}</button>
        {chat_open and <div id="trip-chat" className="fixed bottom-[76px] right-5 z-40 w-[min(390px,calc(100vw-2.5rem))] rounded-2xl border border-[#d9e3de] bg-white p-5 shadow-2xl"><div className="flex items-center justify-between"><div><p className="font-semibold text-[#173c3a]">A little local inspiration</p><p className="mt-1 text-xs text-[#607572]">Try “What should I eat?” or ask about Ella.</p></div><button onClick={lambda { chat_open = False; }} className="rounded-full px-3 py-2 text-sm text-[#607572] hover:bg-[#f3f5f2]" aria-label="Close chat">Close</button></div><a href="#chat-question" className="mt-4 inline-flex rounded-full bg-[#0B3D46] px-4 py-2 text-sm font-semibold text-white">Go to chat <span className="ml-2">→</span></a><p className="mt-3 text-xs leading-5 text-[#778984]">Answers are local guide suggestions, not live AI or real-time travel information.</p></div>}
    </div>;
}
