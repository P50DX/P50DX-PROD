--@base SandLizard
--@colors local C, CL, SP = rgb(110, 34, 26), rgb(170, 70, 36), rgb(255, 120, 20)
-- Ember Lizard (Volcano egg, Common): charcoal-red lizard with glowing ember spots.
for _, p in ipairs({{0.3, -0.5}, {-0.3, -0.1}, {0.25, 0.4}, {-0.2, 0.75}}) do add("Torso", V(0.2, 0.06, 0.2), V(p[1], k.by + 0.39, p[2]), SP, {neon = true}) end
return {name = "EmberLizard", parts = P, joints = J, hrpSize = V(1.6, 1.6, 3), hrpPos = V(0, 0.8, 0)}
