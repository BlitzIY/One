-- 📱 MOBILE AUTO SHIFT LOCK ON JUMP
-- Script de estudo otimizado
-- Versão: 2.0

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Verificação inicial de plataforma
if not UserInputService.TouchEnabled then
	return -- Executa apenas em dispositivos móveis
end

-- Cache de referências
local player = Players.LocalPlayer
local connectionCache = {} -- Para gerenciar conexões
local isShiftLockActive = false
local lastJumpTime = 0
local JUMP_COOLDOWN = 0.5 -- Segundos entre ativações

-- Configurações ajustáveis
local SETTINGS = {
    AutoDisableOnDeath = true,
    EnableCooldown = true,
    ResetOnRespawn = true,
    DebugMode = false -- Ativar para ver logs
}

-- Logger para debug
local function log(message)
    if SETTINGS.DebugMode then
        print("[Mobile Shift Lock]: " .. message)
    end
end

-- Limpa conexões antigas
local function cleanupConnections()
    for name, connection in pairs(connectionCache) do
        if connection then
            connection:Disconnect()
            connectionCache[name] = nil
        end
    end
end

-- Ativa o Shift Lock com verificação de estado
local function enableShiftLock()
    if isShiftLockActive then return end
    
    local currentTime = tick()
    if SETTINGS.EnableCooldown and (currentTime - lastJumpTime) < JUMP_COOLDOWN then
        return
    end
    
    lastJumpTime = currentTime
    isShiftLockActive = true
    
    player.DevEnableMouseLock = true
    player.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
    
    log("Shift Lock ativado")
end

-- Desativa o Shift Lock
local function disableShiftLock()
    if not isShiftLockActive then return end
    
    isShiftLockActive = false
    
    player.DevEnableMouseLock = false
    player.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
    
    log("Shift Lock desativado")
end

-- Verifica se o personagem está no ar
local function isCharacterInAir(humanoid)
    return humanoid:GetState() == Enum.HumanoidStateType.Jumping
        or humanoid:GetState() == Enum.HumanoidStateType.Freefall
        or humanoid:GetState() == Enum.HumanoidStateType.FallingDown
end

-- Handler principal para mudanças de estado
local function setupHumanoidStateHandler(humanoid)
    -- Limpa handler anterior se existir
    if connectionCache.stateChanged then
        connectionCache.stateChanged:Disconnect()
    end
    
    connectionCache.stateChanged = humanoid.StateChanged:Connect(function(oldState, newState)
        -- Ativa ao pular
        if newState == Enum.HumanoidStateType.Jumping then
            enableShiftLock()
        
        -- Desativa ao tocar o chão
        elseif newState == Enum.HumanoidStateType.Landed then
            disableShiftLock()
        
        -- Desativa ao morrer (se configurado)
        elseif SETTINGS.AutoDisableOnDeath and newState == Enum.HumanoidStateType.Dead then
            disableShiftLock()
        end
        
        -- Log de transições de estado (debug)
        if SETTINGS.DebugMode then
            log(string.format("Estado alterado: %s → %s", tostring(oldState), tostring(newState)))
        end
    end)
    
    -- Conexão para resetar ao respawnar
    if SETTINGS.ResetOnRespawn then
        if connectionCache.died then
            connectionCache.died:Disconnect()
        end
        
        connectionCache.died = humanoid.Died:Connect(function()
            log("Personagem morreu - resetando estado")
            disableShiftLock()
        end)
    end
end

-- Handler para quando o personagem é adicionado
local function onCharacterAdded(character)
    log("Novo personagem detectado")
    cleanupConnections()
    disableShiftLock() -- Garante estado inicial limpo
    
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Configura handler de estados
    setupHumanoidStateHandler(humanoid)
    
    -- Verifica estado inicial
    if isCharacterInAir(humanoid) then
        enableShiftLock()
    end
end

-- Handler para quando o personagem é removido
local function onCharacterRemoving()
    log("Personagem removido")
    cleanupConnections()
    disableShiftLock()
end

-- Inicialização
local function initialize()
    log("Script inicializado para: " .. player.Name)
    
    -- Limpeza ao sair
    connectionCache.playerRemoving = player.CharacterRemoving:Connect(onCharacterRemoving)
    connectionCache.characterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    
    -- Caso o personagem já exista
    if player.Character then
        task.spawn(onCharacterAdded, player.Character)
    end
    
    -- Conexão para limpeza ao desconectar
    connectionCache.playerRemoving = player:GetPropertyChangedSignal("Parent"):Connect(function()
        if not player.Parent then
            cleanupConnections()
        end
    end)
end

-- Inicializa com tratamento de erro
local success, err = pcall(initialize)
if not success then
    warn("Erro na inicialização do Mobile Shift Lock: " .. tostring(err))
end

-- Retorna tabela de controle para desenvolvimento (opcional)
return {
    EnableShiftLock = enableShiftLock,
    DisableShiftLock = disableShiftLock,
    ToggleDebug = function()
        SETTINGS.DebugMode = not SETTINGS.DebugMode
        log("Debug mode: " .. tostring(SETTINGS.DebugMode))
    end,
    GetStatus = function()
        return {
            IsActive = isShiftLockActive,
            Settings = SETTINGS
        }
    end
}
