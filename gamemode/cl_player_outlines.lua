local tttrw_outline_roles = CreateConVar("tttrw_outline_roles", "1", FCVAR_ARCHIVE, "See traitor buddies through walls with outlines")

local mat = CreateMaterial("tttrw_player_outline", "VertexLitGeneric", {
	["$basetexture"]    = "color/white",
	["$model"]          = 1,
	["$translucent"]    = 1,
	["$vertexalpha"]    = 1,
    ["$vertexcolor"]    = 1,
})

local incr = 0.01
local scale = Vector(1 + incr * 3, 1 + incr * 3, 1 + incr)

local matr = Matrix()
matr:SetScale(scale)
local matr_zero = Matrix()
function GM:PreDrawOpaqueRenderables()
    if (not tttrw_outline_roles:GetBool()) then
        return
    end

    local r, g, b = render.GetColorModulation()
    render.SetColorModulation(1, 0, 0)
    render.SuppressEngineLighting(true)
    render.MaterialOverride(mat)

    for _, ply in pairs(player.GetAll()) do
        if (ply:GetRoleTeam() ~= "traitor" or not ply:Alive()) then
            continue
        end

        local mn, mx = ply:GetCollisionBounds()

        matr:SetTranslation(Vector(0, 0, -(mx.z - mn.z) * (scale.z - 1) / 2))

        ply:EnableMatrix("RenderMultiply", matr)
        ply:SetupBones()

            ply:DrawModel()

        ply:EnableMatrix("RenderMultiply", matr_zero)
        ply:SetupBones()
    end

    render.MaterialOverride()
    render.SuppressEngineLighting(false)
    render.SetColorModulation(r, g, b)
end