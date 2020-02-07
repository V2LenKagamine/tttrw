resource.AddFile "sound/tttrw/hitmarker_.mp3"
resource.AddFile "sound/tttrw/hitmarker_hs.wav"

function GM:CreateHitmarkers(vic, dmg)
    local atk = dmg:GetAttacker()

    if (not IsValid(atk) or not vic:IsPlayer() or dmg:GetDamage() <= 0) then
        return
    end

    if (not hook.Run("PlayerShouldTakeDamage", vic, atk)) then
        return
    end

    local hitmarker = ents.Create "ttt_damagenumber"
    hitmarker:SetOwner(atk)
    hitmarker:SetRealDamage(dmg:GetDamage(), 1)
    hitmarker:SetDamageType(dmg:GetDamageType())
    hitmarker:SetPos(dmg:GetDamagePosition())
    hitmarker:SetHitGroup(dmg:GetDamageCustom())
    hitmarker:Spawn()
end