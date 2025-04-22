AddCSLuaFile()

SWEP.HoldType           = "slam"

SWEP.PrintName          = "Incendiary Grenade"
SWEP.Slot               = 3

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.Primary.Delay = 3

SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.ViewModel             = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.GrenadeEntity = "ttt_basegrenade"


SWEP.ThrowVelocity = 800
SWEP.Bounciness = 0.3
SWEP.DamageMultiplier = 1
SWEP.RangeMultiplier = 1
SWEP.ThrowMultiplier = 1


DEFINE_BASECLASS "weapon_tttbase"
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetVar("ThrowStart", "Float", math.huge)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetThrowStart(CurTime())

	self:PullPin()
end

function SWEP:Throw()
	local e
	if (SERVER) then
		e = ents.Create(self.GrenadeEntity)
		e.DoRemove = true
	end

	if (IsValid(e)) then
		e:SetOrigin(self:GetOwner():EyePos())
		e:SetOwner(self:GetOwner())
		e.Owner = self:GetOwner()
		e:SETVelocity((self:GetOwner():GetAimVector() * self.ThrowVelocity + self:GetOwner():GetVelocity() * 0.8) * self.ThrowMultiplier)
		e:SetDieTime(self:GetThrowStart() + self.Primary.Delay)
		e:SetBounciness(self.Bounciness)
		e:SetWeapon(self)
		e:Spawn()

        self:TakePrimaryAmmo(1)
		self:SetThrowStart(math.huge)
        if (self.Weapon:Clip1() <= 0) then
		    hook.Run("DropCurrentWeapon", self:GetOwner())
		    self:Remove()
        end
	end
end

function SWEP:Think()
	if (self:GetThrowStart() ~= math.huge and (not self:GetOwner():KeyDown(IN_ATTACK) or self:GetThrowStart() + self.Primary.Delay < CurTime())) then
		self:Throw()
	end
end

function SWEP:PullPin()
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	self:SetHoldType "grenade"
end

function SWEP:SecondaryAttack()
end

function SWEP:TranslateFOV(fov)
	return hook.Run("TTTGetFOV", fov) or fov
end

function SWEP:PreDrop()
	if (self:GetThrowStart() ~= math.huge) then
		return true
	end
end

function SWEP:Holster()
	if (self:GetThrowStart() ~= math.huge) then
		return false
	end

	return BaseClass.Holster(self)
end

SWEP.Ortho = {-2, 3, angle = Angle(-40, 20, 45)}
