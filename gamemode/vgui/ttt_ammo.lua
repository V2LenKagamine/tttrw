local PANEL = {}

function PANEL:Init()
	self:AddFunction("ttt", "ready", function()
		self.Ready = true
	end)
	
	self:SetHTML [[
        <head>
			<style>
				* {
					-webkit-font-smoothing: antialiased;
					-moz-osx-font-smoothing: grayscale;
					line-height: 15px;
                }
                /* latin */
                @font-face {
					font-family: 'Lato';
					font-style: normal;
					font-weight: 400;
					src: local('Lato Regular'), local('Lato-Regular'), url(https://fonts.gstatic.com/s/lato/v16/S6uyw4BMUTPHjx4wXg.woff2) format('woff2');
					unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
                }
				h1 {
					font-size: 30px;
					font-family: 'Lato', sans-serif;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
					color: #F7F7F7;
				}
				h2 {
					font-size: 23px;
					font-family: 'Lato', sans-serif;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
					color: #F7F7F7;
				}
				.shadow {
				  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				}
			</style>
		</head>
		<body onload="ttt.ready()">
			<h1 id="ammoCounter" class="shadow" />
			<h2 id="reserveAmmo" class="shadow" />
			<img src="asset://garrysmod/materials/tttrw/heart.png" width="48">
			<script>
				var ammoCounter = document.getElementById("ammoCounter");
				var reserveAmmo = document.getElementById("reserveAmmo");
				
				
				var ammo = 0;
				var maxAmmo = 0;
				
				
				function setAmmo(_ammo)
				{
					ammo = _ammo
					
					ammoCounter.innerHTML = _ammo + "/" + maxAmmo
				}
				
				function setMaxAmmo(_maxAmmo)
				{
					maxAmmo = _maxAmmo
					
					ammoCounter.innerHTML = ammo + "/" + _maxAmmo
				}
				
				function setAllAmmo(_ammo, _maxAmmo, _reserve)
				{
					ammo = _ammo
					maxAmmo = _maxAmmo
					
					ammoCounter.innerHTML = _ammo + "/" + _maxAmmo
					reserveAmmo.innerHTML = _reserve
				}
				
				function setReserveAmmo(_reserve)
				{
					reserveAmmo.innerHTML = _reserve
				}
			</script>
		</body>
	]]
	
	self.OldAmmo = 0
	self.ReserveAmmo = 0

	hook.Add("PlayerSwitchWeapon", self, self.PlayerSwitchWeapon)
end

function PANEL:OnRemove()
	timer.Destroy("ttt_DHTML_Ammo_Timer")
end

function PANEL:UpdateAllAmmo(pl, wep)
	if (not IsValid(wep)) then return end
	
	local max_bullets = wep.Primary and wep.Primary.ClipSize or wep:Clip1()
	local cur_bullets = wep:Clip1()
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	
	self.OldAmmo = cur_bullets
	self.ReserveAmmo = reserve
	
	self:CallSafe([[setAllAmmo("%s", "%s", "%s")]], cur_bullets, max_bullets, reserve)
end

function PANEL:PlayerSwitchWeapon(pl, old, new)
	if (pl ~= self:GetTarget()) then return end

	self:UpdateAllAmmo(pl, new)
end

function PANEL:PerformLayout()
	self:SetPos(ScrW() * 0.85625, ScrH() * 0.777)
	self:SetSize(ScrW() * 0.125, ScrH() * 0.33)

	local pl = self:GetTarget()
	self:UpdateAllAmmo(pl, pl:GetActiveWeapon())
	
	timer.Create("ttt_DHTML_Ammo_Timer", 0.1, 0, function() self:Tick() end)
end

function PANEL:Tick()
	if (not self.Ready) then return end
	
	local pl = self:GetTarget()
	local wep = pl:GetActiveWeapon()
	if (not IsValid(wep)) then return end

	local cur_bullets = wep:Clip1()
	if (self.OldAmmo ~= cur_bullets) then
		self.OldAmmo = cur_bullets
		self:CallSafe([[setAmmo("%s")]], cur_bullets)
	end
	
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	if (self.ReserveAmmo ~= reserve) then
		self.ReserveAmmo = reserve
		self:CallSafe([[setReserveAmmo("%s")]], reserve)
	end
end

vgui.Register("ttt_ammo", PANEL, "ttt_html_base")