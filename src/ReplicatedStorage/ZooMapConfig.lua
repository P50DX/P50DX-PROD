-- ZooMapConfig (ModuleScript -> ReplicatedStorage)
-- The numbers the map SHOWS (stage gates, reward pads, speed upgrades, treadmills, eggs) and the hooks it calls.
-- Your real game already has its own values: when this map goes into the real place, point each field at your
-- existing config (or copy your numbers in). Nothing here changes your game's balancing - it is display + hooks.
-- Values from your screenshots are filled in; everything else marked TEST is a stand-in for the test place only.

local C = {}

-- x2 Wins / Skip Stage purchases. No Product IDs yet -> TestMode lets them work for free in Studio.
C.Products = {
	DoubleWins = nil, -- Developer Product ID for the purple x2 Wins pad
	SkipStage = nil, -- Developer Product ID for the green Skip Stage pad
}
C.TestMode = true
-- after claiming a stage reward (yellow / purple) the player goes back to the world's spawn
C.ReturnToHubAfterReward = true

-- per world: hub origin, spawn, and the 10 stages. Stage 1/2 values are from your screenshots; the rest are TEST.
C.Worlds = {
	{
		id = 1, key = "Zoo", name = "ZOO",
		stages = {
			{ recommendedLevel = 3, speedRequired = 10, wins = 1 },
			{ recommendedLevel = 6, speedRequired = 16, wins = 1 },
			{ recommendedLevel = 9, speedRequired = 25, wins = 2 }, -- TEST
			{ recommendedLevel = 15, speedRequired = 75, wins = 2 }, -- TEST (your example in the brief)
			{ recommendedLevel = 20, speedRequired = 120, wins = 3 }, -- TEST
			{ recommendedLevel = 26, speedRequired = 200, wins = 3 }, -- TEST
			{ recommendedLevel = 33, speedRequired = 320, wins = 4 }, -- TEST
			{ recommendedLevel = 40, speedRequired = 500, wins = 5 }, -- TEST
			{ recommendedLevel = 48, speedRequired = 750, wins = 6 }, -- TEST
			{ recommendedLevel = 56, speedRequired = 1100, wins = 8 }, -- TEST
		},
		speedUpgrades = { -- TEST
			{ plus = 1, wins = 0 }, { plus = 2, wins = 5 }, { plus = 4, wins = 15 }, { plus = 8, wins = 40 }, { plus = 15, wins = 100 },
			{ plus = 25, wins = 250 }, { plus = 50, wins = 600 }, { plus = 100, wins = 1500 }, { plus = 200, wins = 4000 }, { plus = 500, wins = 10000 },
		},
		treadmills = { 2, 3, 5, 10 }, -- TEST multipliers per treadmill tier
		egg = {
			name = "ZooEgg", display = "Zoo Egg", price = "TEST 100",
			pets = { "BabyChick", "Piglet", "MiniBee", "Puppy", "BabyPanda" },
		},
		nextWorld = "Desert", prevWorld = nil,
	},
	{ -- TEST values (your real numbers replace these)
		id = 2, key = "Desert", name = "DESERT",
		stages = {
			{ recommendedLevel = 9, speedRequired = 60, wins = 2 },
			{ recommendedLevel = 18, speedRequired = 132, wins = 2 },
			{ recommendedLevel = 28, speedRequired = 348, wins = 4 },
			{ recommendedLevel = 37, speedRequired = 708, wins = 4 },
			{ recommendedLevel = 46, speedRequired = 1212, wins = 6 },
			{ recommendedLevel = 56, speedRequired = 1860, wins = 6 },
			{ recommendedLevel = 65, speedRequired = 2652, wins = 8 },
			{ recommendedLevel = 74, speedRequired = 3588, wins = 8 },
			{ recommendedLevel = 84, speedRequired = 4668, wins = 10 },
			{ recommendedLevel = 93, speedRequired = 5892, wins = 10 },
		},
		speedUpgrades = { { plus = 5, wins = 0 }, { plus = 10, wins = 25 }, { plus = 20, wins = 75 }, { plus = 40, wins = 200 }, { plus = 75, wins = 500 }, { plus = 125, wins = 1250 }, { plus = 250, wins = 3000 }, { plus = 500, wins = 7500 }, { plus = 1000, wins = 20000 }, { plus = 2500, wins = 50000 } },
		treadmills = { 4, 6, 10, 20 },
		egg = { name = "DesertEgg", display = "Desert Egg", price = "TEST 1000", pets = { "FennecFox", "SandLizard", "BabyCamel", "SunScarab", "SphinxCat" } },
		nextWorld = "Snow", prevWorld = "Zoo",
	},
	{ -- TEST values (your real numbers replace these)
		id = 3, key = "Snow", name = "SNOW",
		stages = {
			{ recommendedLevel = 14, speedRequired = 600, wins = 3 },
			{ recommendedLevel = 28, speedRequired = 1320, wins = 3 },
			{ recommendedLevel = 42, speedRequired = 3480, wins = 6 },
			{ recommendedLevel = 56, speedRequired = 7080, wins = 6 },
			{ recommendedLevel = 70, speedRequired = 12120, wins = 9 },
			{ recommendedLevel = 84, speedRequired = 18600, wins = 9 },
			{ recommendedLevel = 98, speedRequired = 26520, wins = 12 },
			{ recommendedLevel = 112, speedRequired = 35880, wins = 12 },
			{ recommendedLevel = 126, speedRequired = 46680, wins = 15 },
			{ recommendedLevel = 140, speedRequired = 58920, wins = 15 },
		},
		speedUpgrades = { { plus = 50, wins = 0 }, { plus = 100, wins = 250 }, { plus = 200, wins = 750 }, { plus = 400, wins = 2000 }, { plus = 750, wins = 5000 }, { plus = 1250, wins = 12500 }, { plus = 2500, wins = 30000 }, { plus = 5000, wins = 75000 }, { plus = 10000, wins = 200000 }, { plus = 25000, wins = 500000 } },
		treadmills = { 6, 9, 15, 30 },
		egg = { name = "SnowEgg", display = "Snow Egg", price = "TEST 10000", pets = { "SnowBunny", "BabyPenguin", "CrystalFox", "IceOwl", "FrostWolfPup" } },
		nextWorld = "Forest", prevWorld = "Desert",
	},
	{ -- TEST values (your real numbers replace these)
		id = 4, key = "Forest", name = "FOREST",
		stages = {
			{ recommendedLevel = 19, speedRequired = 6000, wins = 4 },
			{ recommendedLevel = 37, speedRequired = 13200, wins = 4 },
			{ recommendedLevel = 56, speedRequired = 34800, wins = 8 },
			{ recommendedLevel = 75, speedRequired = 70800, wins = 8 },
			{ recommendedLevel = 93, speedRequired = 121200, wins = 12 },
			{ recommendedLevel = 112, speedRequired = 186000, wins = 12 },
			{ recommendedLevel = 131, speedRequired = 265200, wins = 16 },
			{ recommendedLevel = 149, speedRequired = 358800, wins = 16 },
			{ recommendedLevel = 168, speedRequired = 466800, wins = 20 },
			{ recommendedLevel = 187, speedRequired = 589200, wins = 20 },
		},
		speedUpgrades = { { plus = 500, wins = 0 }, { plus = 1000, wins = 2500 }, { plus = 2000, wins = 7500 }, { plus = 4000, wins = 20000 }, { plus = 7500, wins = 50000 }, { plus = 12500, wins = 125000 }, { plus = 25000, wins = 300000 }, { plus = 50000, wins = 750000 }, { plus = 100000, wins = 2000000 }, { plus = 250000, wins = 5000000 } },
		treadmills = { 8, 12, 20, 40 },
		egg = { name = "ForestEgg", display = "Forest Egg", price = "TEST 100000", pets = { "BabyDeer", "OwlChick", "RedPanda", "BabyBear", "ForestSpirit" } },
		nextWorld = "Volcano", prevWorld = "Snow",
	},
	{ -- TEST values (your real numbers replace these)
		id = 5, key = "Volcano", name = "VOLCANO",
		stages = {
			{ recommendedLevel = 24, speedRequired = 60000, wins = 5 },
			{ recommendedLevel = 47, speedRequired = 132000, wins = 5 },
			{ recommendedLevel = 70, speedRequired = 348000, wins = 10 },
			{ recommendedLevel = 94, speedRequired = 708000, wins = 10 },
			{ recommendedLevel = 117, speedRequired = 1212000, wins = 15 },
			{ recommendedLevel = 140, speedRequired = 1860000, wins = 15 },
			{ recommendedLevel = 164, speedRequired = 2652000, wins = 20 },
			{ recommendedLevel = 187, speedRequired = 3588000, wins = 20 },
			{ recommendedLevel = 210, speedRequired = 4668000, wins = 25 },
			{ recommendedLevel = 234, speedRequired = 5892000, wins = 25 },
		},
		speedUpgrades = { { plus = 5000, wins = 0 }, { plus = 10000, wins = 25000 }, { plus = 20000, wins = 75000 }, { plus = 40000, wins = 200000 }, { plus = 75000, wins = 500000 }, { plus = 125000, wins = 1250000 }, { plus = 250000, wins = 3000000 }, { plus = 500000, wins = 7500000 }, { plus = 1000000, wins = 20000000 }, { plus = 2500000, wins = 50000000 } },
		treadmills = { 10, 15, 25, 50 },
		egg = { name = "VolcanoEgg", display = "Volcano Egg", price = "TEST 1000000", pets = { "EmberLizard", "MagmaSlime", "FireBat", "LavaPup", "BabyDragon" } },
		nextWorld = "Space", prevWorld = "Forest",
	},
	{ -- TEST values (your real numbers replace these)
		id = 6, key = "Space", name = "SPACE",
		stages = {
			{ recommendedLevel = 28, speedRequired = 600000, wins = 6 },
			{ recommendedLevel = 56, speedRequired = 1320000, wins = 6 },
			{ recommendedLevel = 84, speedRequired = 3480000, wins = 12 },
			{ recommendedLevel = 112, speedRequired = 7080000, wins = 12 },
			{ recommendedLevel = 140, speedRequired = 12120000, wins = 18 },
			{ recommendedLevel = 168, speedRequired = 18600000, wins = 18 },
			{ recommendedLevel = 196, speedRequired = 26520000, wins = 24 },
			{ recommendedLevel = 224, speedRequired = 35880000, wins = 24 },
			{ recommendedLevel = 252, speedRequired = 46680000, wins = 30 },
			{ recommendedLevel = 280, speedRequired = 58920000, wins = 30 },
		},
		speedUpgrades = { { plus = 50000, wins = 0 }, { plus = 100000, wins = 250000 }, { plus = 200000, wins = 750000 }, { plus = 400000, wins = 2000000 }, { plus = 750000, wins = 5000000 }, { plus = 1250000, wins = 12500000 }, { plus = 2500000, wins = 30000000 }, { plus = 5000000, wins = 75000000 }, { plus = 10000000, wins = 200000000 }, { plus = 25000000, wins = 500000000 } },
		treadmills = { 12, 18, 30, 60 },
		egg = { name = "SpaceEgg", display = "Space Egg", price = "TEST 10000000", pets = { "MoonBunny", "StarPup", "CometCat", "NebulaOwl", "GalaxyDragon" } },
		nextWorld = nil, prevWorld = "Volcano",
	},
}

C.Rarity = {
	BabyChick = "Common", Piglet = "Uncommon", MiniBee = "Rare", Puppy = "Epic", BabyPanda = "Legendary",
	FennecFox = "Common", SandLizard = "Uncommon", BabyCamel = "Rare", SunScarab = "Epic", SphinxCat = "Legendary",
	SnowBunny = "Common", BabyPenguin = "Uncommon", CrystalFox = "Rare", IceOwl = "Epic", FrostWolfPup = "Legendary",
	BabyDeer = "Common", OwlChick = "Uncommon", RedPanda = "Rare", BabyBear = "Epic", ForestSpirit = "Legendary",
	EmberLizard = "Common", MagmaSlime = "Uncommon", FireBat = "Rare", LavaPup = "Epic", BabyDragon = "Legendary",
	MoonBunny = "Common", StarPup = "Uncommon", CometCat = "Rare", NebulaOwl = "Epic", GalaxyDragon = "Legendary",
}
-- hub origins (studs) of each world; the race map sits south of the Zoo
C.Origins = { Vector3.new(3000, 100, 0), Vector3.new(7500, 100, 0), Vector3.new(12000, 100, 0), Vector3.new(16500, 100, 0), Vector3.new(21000, 100, 0), Vector3.new(25500, 100, 0) }
-- Speed Race event (TEST values): seconds between races, lobby time, max race time, Wins for 1st/2nd/3rd
C.Race = { Interval = 300, LobbyTime = 25, MaxTime = 90, Rewards = { 3, 2, 1 } }
C.RaceOrigin = Vector3.new(3000, 100, 2600)
C.WorldIndex = { Zoo = 1, Desert = 2, Snow = 3, Forest = 4, Volcano = 5, Space = 6 }
C.RarityColor = {
	Common = Color3.fromRGB(210, 210, 210), Uncommon = Color3.fromRGB(110, 230, 110), Rare = Color3.fromRGB(80, 170, 255),
	Epic = Color3.fromRGB(190, 100, 255), Legendary = Color3.fromRGB(255, 200, 40),
}

-- Hooks your existing systems connect to (ObbyService fires these; the test place just adds leaderstats Wins).
--   ServerStorage.ZooMapHooks.GrantReward (BindableEvent): (player, worldId, stage, wins, kind)
--   ServerStorage.ZooMapHooks.StageReached (BindableEvent): (player, worldId, stage)
-- Player attributes the map reads/writes: "Stage_<worldId>" (highest checkpoint reached). Save it with your
-- DataStore code (load it before the character spawns and the player starts at that checkpoint).

return C
