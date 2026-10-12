-- VariantRainbow (LocalScript -> StarterPlayer/StarterPlayerScripts)
-- Starts the single shared loop that animates every Rainbow-variant animal (see ReplicatedStorage.AnimalVariants).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("AnimalVariants")).startRainbow()
