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
}

C.Rarity = {
	BabyChick = "Common", Piglet = "Uncommon", MiniBee = "Rare", Puppy = "Epic", BabyPanda = "Legendary",
}
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
