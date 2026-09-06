require "Spouse/SpouseConfig"

SpouseDialogue = SpouseDialogue or {}

SpouseDialogue.lines = {
    introduction = {
        "I'm here. Let's survive this together.",
        "No matter what happened, we still have each other.",
        "I'm ready when you are. Just point the way.",
    },
    follow = {
        "I'm right behind you.",
        "I'll stay close.",
        "Lead the way.",
    },
    stay = {
        "I'll hold here.",
        "I'll keep watch from here.",
        "I'll wait for you.",
    },
    home = {
        "I'll head back and lock things down.",
        "I'll return home and wait for you there.",
        "I'll fall back to the safehouse.",
    },
    talk = {
        "We're still in this together.",
        "You don't have to do this alone.",
        "One more day survived is still a win.",
    },
    rally = {
        "I found you again.",
        "Back with you now.",
        "I caught up. Let's keep moving.",
    },
    setHome = {
        "This feels safe enough to call home.",
        "I'll remember this place.",
        "Safehouse marked.",
    },
}

function SpouseDialogue.pick(key)
    local bucket = SpouseDialogue.lines[key]

    if not bucket or #bucket == 0 then
        return "..."
    end

    return bucket[ZombRand(#bucket) + 1]
end
