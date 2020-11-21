# MecAlarm
A World of Warcraft addon to help with various raid encounters in The Burning Crusade expansion.

Currently, it does the following:

- Automatically unequips and re-equips the weapons of Hunters, Rogues, Retribution Paladins, Fury Warriors, Arms Warriors, and Enhancement Shamans during phase 3 of the Lady Vashj encounter in SSC in order to play around her Persuasion spell (her mind control).

    - A demostration of this feature can be seen here: https://www.youtube.com/watch?v=BQOrhY8IgCg&feature=youtu.be
    - **WARNING**: It does not work correctly if both of your weapons have the same name.
    - **WARNING**: It snapshots the weapons weapon(s) you have equipped upon entering phase 3 of the fight. This is can be problematic in certain situations, such as enhancement shamans who swap in a third weapon like Annihilator.

- During the High Astromancer Solarian fight in Tempest Keep, it turns your screen green when you have the DoT version of Wrath of the Astromancer debuff and turns your screen blue when you have the lingering non-DoT version of the Wrath of the Astromancer debuff. Also, a frame will appear with a summary of the raid's debuff situation.

    - A demostration of this feature can be seen here: https://www.youtube.com/watch?v=Pr97_a3QN7U&feature=youtu.be
    - The text in the frame follows a pattern of `[Ax] <PlayerName>: B`, where A represents how many stacks of the DoT Wrath of the Astromancer debuff they have and B represents how many stacks of the non-DoT Wrath of the Astromancer debuff they have. Due to limitations in the TBC API, the value for A will only appear for players in your raid who also have this addon installed, but you will see the value for B for everyone in your raid as long as you have this addon installed.

# Installation

Go to https://github.com/MecAtlantiss/MecAlarm/releases to download the latest release. Once downloaded, extract the addon's folder and place it into the Interfaces/Addons folder of your WoW installation.

# Known bugs

* Addon will some times throw errors upon entering The Eye raid. The workaround is to reload your UI.

# TODO

* Add in-game commands or a GUI to allow players to change settings (e.g. disable certain features of the addon).
