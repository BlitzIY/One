-- 📱 MOBILE AUTO SHIFT LOCK AO PULAR
-- Script para ESTUDO

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Verifica se é mobile
if not UserInputService.TouchEnabled then
	return -- Sai do script se NÃO for mobile
end

-- Função quando o personagem spawnar
local function onCharacterAdded(character)
	
	local humanoid = character:WaitForChild("Humanoid")

	-- Detecta mudanças de estado do Humanoid
	humanoid.StateChanged:Connect(function(oldState, newState)

		-- Quando o jogador PULAR
		if newState == Enum.HumanoidStateType.Jumping then
			
			-- Ativa o "Shift Lock"
			player.DevEnableMouseLock = true
			player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable

		end

		-- Quando tocar o chão
		if newState == Enum.HumanoidStateType.Landed then
			
			-- Desativa o "Shift Lock"
			player.DevEnableMouseLock = false
			player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice

		end
	end)
end

-- Conecta quando o personagem aparecer
player.CharacterAdded:Connect(onCharacterAdded)

-- Caso o personagem já exista
if player.Character then
	onCharacterAdded(player.Character)
end
