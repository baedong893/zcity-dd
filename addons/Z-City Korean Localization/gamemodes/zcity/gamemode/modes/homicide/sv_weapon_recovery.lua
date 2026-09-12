local MODE = MODE

MODE.PlacedWeaponRecoveryRoles = {
	["weapon_beartrap_homigrad"] = "traitor_cannibal"
}

function MODE:HG_CanRecoverPlacedWeapon(ply, weaponClass)
	local requiredRole = self.PlacedWeaponRecoveryRoles[weaponClass]
	if not requiredRole then return end

	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return false end
	if ply:Team() == TEAM_SPECTATOR or zb.ROUND_STATE ~= 1 then return false end
	if not ply.isTraitor or ply.SubRole ~= requiredRole then return false end
	-- Leave other recovery restrictions free to veto even an eligible role.
end
