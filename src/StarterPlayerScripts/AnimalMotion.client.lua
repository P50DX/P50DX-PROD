-- AnimalMotion (LocalScript -> StarterPlayer/StarterPlayerScripts)
-- Starts the single procedural animation loop for every animal, pet and zookeeper (ReplicatedStorage.AnimalMotion).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("AnimalMotion")).start()
