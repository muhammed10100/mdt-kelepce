local dragStatus, playerData, tirman, poliskelepceledi, oyuncukelepceledi, benkelepceledim, isDead, sistemAktif, Baslat = {}, {}, 0, false, false, false, false, true, false
dragStatus.isDragged = false

QBCore = nil
Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
    Baslat = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    OyundaSimdi()
end)

function OyundaSimdi()
    PlayerData = QBCore.Functions.GetPlayerData()
    oyuncukelepceledi = PlayerData.metadata["kelepcelinormal"]
    poliskelepceledi = PlayerData.metadata["kelepceli"]
end

AddEventHandler('mdt:playerdead', function(dead)
    isDead = dead
end)

-- Meslek Update
RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('tigann-kelepce:aktif-pasif')
AddEventHandler('tigann-kelepce:aktif-pasif', function(durum)
    if durum then
        sistemAktif = true
    else
        sistemAktif = false
    end
end)

Citizen.CreateThread(function()
    while QBCore == nil do Citizen.Wait(1) end
    while true do
        local time = 1000
        if Baslat then
            if poliskelepceledi or oyuncukelepceledi then
                time = 1
                local playerPed = PlayerPedId()
                if not IsPedRagdoll(playerPed) then
                    if not IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) then
                    --     TriggerEvent("disc-inventoryhud:remove-weapon")
                        QBCore.Shared.RequestAnimDict('mp_arresting', function()
                            TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, 8.0, -1, 49, 0, 0, 0, 0)
                        end)
                    end

                    if IsPedClimbing(playerPed) then
                        tirman = tirman + 1
                        if tirman > 40 then
                            SetPedToRagdoll(playerPed, 2000, 2000, 0, 0, 0, 0)
                            Citizen.Wait(2000)
                        end
                    else
                        tirman = 0
                    end
                end
            end
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 1.5 then
                -- -- if PlayerData.job.name == 'police' then
                    time = 1

                    -- if IsControlJustPressed(0, 125) then
                    --     TriggerEvent('mdt-kelepce:client:tasi')
                    -- end
                -- end
            end
        end
        Citizen.Wait(time)
    end
end)

-- Polis Kelepçeleme
RegisterNetEvent("mdt-kelepce:polis-kelepce-tak-client")
AddEventHandler("mdt-kelepce:polis-kelepce-tak-client", function()
    if sistemAktif then
        QBCore.Functions.TriggerCallback('mdt-base-item-kontrol', function(qtty)
        if qtty >= 1 then
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 1.5 then
                    local targetPlayerPed = GetPlayerServerId(closestPlayer)
                    QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                        if not data.kelepce and not data.pkelepce then
                            playerPed = PlayerPedId()
                            kordinat()
                            TriggerServerEvent("mdt-kelepce:polis-kelepce-tak-takilan", targetPlayerPed, playerlocation, playerheading, playerCoords)
                            Citizen.Wait(200)
                            kelepceSound()
                            QBCore.Shared.RequestAnimDict('mp_arrest_paired', function()
                                TaskPlayAnim(playerPed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0) -- Kelepce Takma
                                -- TriggerServerEvent("mdt-kelepce:polis-kelepce-tak-takan")
                            end)
                        else
                            QBCore.Functions.Notify('Kişi Zaten Kelepçeli!')
                        end
                    end, targetPlayerPed)
                else
                    QBCore.Functions.Notify('Yakında Kimse Yok!')
                end
            else
                QBCore.Functions.Notify('Üstünüzde Kelepçe Yok!')
            end
        end, "pkelepce")
    end
end)

RegisterNetEvent("mdt-kelepce:polis-kelepce-tak-yakin-oyuncu-client")
AddEventHandler("mdt-kelepce:polis-kelepce-tak-yakin-oyuncu-client", function(playerlocation, playerheading, playerCoords, takan)
    local playerPed = PlayerPedId()
    --konumaldir(playerPed, playerlocation, playerheading, playerCoords)

    Citizen.CreateThread(function()
        QBCore.Shared.RequestAnimDict('mp_arrest_paired', function()
            TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 5300 , 2, 0, 0, 0, 0) -- Kelepçelenme Anim            
        end)
    end)
    
    local finished = exports["mdt-skillbar"]:taskBar(750, math.random(10, 15))
    if not finished then
        Citizen.Wait(4550)
        QBCore.Shared.RequestAnimDict('mp_arresting', function()
            TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)  -- Eller Arakada Kelepçeli Anim
            poliskelepceledi = true
        end)
        poliskelepceledi = true
    else
        TriggerServerEvent("mdt-kelepce:anim-cancel", takan, "police")
    end

end) 

RegisterNetEvent("mdt-kelepce:client:anim-cancel")
AddEventHandler("mdt-kelepce:client:anim-cancel", function()
    Citizen.Wait(5300)
    ClearPedTasksImmediately(PlayerPedId())
end)

-- Polis Kelepçe çöz
RegisterNetEvent("mdt-kelepce:polis-kelepce-coz-client")
AddEventHandler("mdt-kelepce:polis-kelepce-coz-client", function()
    QBCore.Functions.TriggerCallback('mdt-base-item-kontrol', function(qtty)
        if qtty >= 1 then
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 1.5 then
                local targetPlayerPed = GetPlayerServerId(closestPlayer)  
                QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                    if data.pkelepce then
                        playerPed = PlayerPedId()
                        kordinat()
                        TriggerServerEvent("mdt-kelepce:polis-kelepce-coz-takilan", targetPlayerPed, playerlocation, playerheading, playerCoords)
                        mansetSound()
                        QBCore.Shared.RequestAnimDict('mp_arresting', function()
                            TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
                            TriggerServerEvent("mdt-kelepce:polis-kelepce-coz-takan")
                            Citizen.Wait(6000)
                            ClearPedTasksImmediately(playerPed)
                        end)
                    elseif data.kelepce then
                        QBCore.Functions.Notify('Elinizdeki Anahtar Bu Kelepçenin Değil!')
                    elseif not data.pkelepce or not data.kelepce then
                        QBCore.Functions.Notify('Kişi Zaten Kelepçeli Değil!')
                    end
                end, targetPlayerPed)
            else
                QBCore.Functions.Notify('Yakında Kimse Yok!')
            end
        else
            QBCore.Functions.Notify('Üstünüzde Anahtar Yok!')
        end 
    end, "pkelepceanahtar")
end)

RegisterNetEvent("mdt-kelepce:polis-kelepce-coz-yakin-oyuncu-client")
AddEventHandler("mdt-kelepce:polis-kelepce-coz-yakin-oyuncu-client", function(playerlocation, playerheading, playerCoords)
    local playerPed = PlayerPedId()
    --konumaldir(playerPed, playerlocation, playerheading, playerCoords)
    
    QBCore.Shared.RequestAnimDict('mp_arresting', function()
        TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
        Citizen.Wait(6000)
        poliskelepceledi = false
        ClearPedTasksImmediately(playerPed)
    end)
end) 

-- Normal Kelepçeleme
RegisterNetEvent("mdt-kelepce:kelepce-tak-client")
AddEventHandler("mdt-kelepce:kelepce-tak-client", function()
  if sistemAktif then
        QBCore.Functions.TriggerCallback('mdt-base-item-kontrol', function(qtty)
            if qtty >= 1 then
                local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 1.5 then
                    local targetPlayerPed = GetPlayerServerId(closestPlayer)  
                    QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                        if not data.kelepce and not data.pkelepce then
                           -- playerPed = PlayerPedId()
                            kordinat()
                            TriggerServerEvent("mdt-kelepce:kelepce-tak-takilan", targetPlayerPed, playerlocation, playerheading, playerCoords)
                            Citizen.Wait(200)
                            kelepceSound()
                            QBCore.Shared.RequestAnimDict('mp_arrest_paired', function()
                                TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0) -- Kelepce Takma
                                -- TriggerServerEvent("mdt-kelepce:kelepce-tak-takan")
                                benkelepceledim = true
                            end)
                        else
                            QBCore.Functions.Notify('Kişi Zaten Kelepçeli!')
                        end
                    end, targetPlayerPed)
                else
                    QBCore.Functions.Notify('Yakında Kimse Yok!')
                end
            else
                QBCore.Functions.Notify('Üstünüzde Kelepçe Yok!')
            end
        end, "kelepce")
    end
end)

RegisterNetEvent("mdt-kelepce:kelepce-tak-yakin-oyuncu-client")
AddEventHandler("mdt-kelepce:kelepce-tak-yakin-oyuncu-client", function(playerlocation, playerheading, playerCoords, takan)
    local playerPed = PlayerPedId()
    --konumaldir(playerPed, playerlocation, playerheading, playerCoords)

    local finished = exports["qb-skillbar"]:taskBar(750,math.random(10,15))
    if not finished then
        QBCore.Shared.RequestAnimDict('mp_arrest_paired', function()
            TaskPlayAnim(PlayerPedId(), 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0) -- Kelepçelenme Anim
            Citizen.Wait(5000)
            QBCore.Shared.RequestAnimDict('mp_arresting', function()
                TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)  -- Eller Arakada Kelepçeli Anim
                oyuncukelepceledi = true
            end)
        end)
    else
        TriggerServerEvent("mdt-kelepce:anim-cancel", takan, "normal")
    end
end)

-- Normal Kelepçe çöz
RegisterNetEvent("mdt-kelepce:kelepce-coz-client")
AddEventHandler("mdt-kelepce:kelepce-coz-client", function()
    QBCore.Functions.TriggerCallback('mdt-base-item-kontrol', function(qtty)
        if qtty >= 1 then
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 1.5 then
                local targetPlayerPed = GetPlayerServerId(closestPlayer)  
                QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                    if data.kelepce and benkelepceledim then
                        playerPed = PlayerPedId()
                        kordinat()
                        TriggerServerEvent("mdt-kelepce:kelepce-coz-takilan", targetPlayerPed, playerlocation, playerheading, playerCoords)
                        mansetSound()
                        QBCore.Shared.RequestAnimDict('mp_arresting', function()
                            TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'a_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
                            TriggerServerEvent("mdt-kelepce:kelepce-coz-takan")
                            Citizen.Wait(6000)
                            ClearPedTasksImmediately(playerPed)
                        end)
                    elseif not data.pkelepce and not data.kelepce then
                        QBCore.Functions.Notify('Kişi Zaten Kelepçeli Değil!')
                    elseif data.pkelepce or not benkelepceledim then
                        QBCore.Functions.Notify('Elinizdeki Anahtar Bu Kelepçenin Değil!')
                    end
                end, targetPlayerPed)
            else
                QBCore.Functions.Notify('Yakında Kimse Yok!')
            end
        else
            QBCore.Functions.Notify('Üstünüzde Anahtar Yok!')
        end 
    end, "kelepceanahtar")
end)

RegisterNetEvent("mdt-kelepce:kelepce-coz-yakin-oyuncu-client")
AddEventHandler("mdt-kelepce:kelepce-coz-yakin-oyuncu-client", function(playerlocation, playerheading, playerCoords)
    playerPed = PlayerPedId()
    --konumaldir(playerPed, playerlocation, playerheading, playerCoords)
    QBCore.Shared.RequestAnimDict('mp_arresting', function()
        TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'b_uncuff', 8.0, -8,-1, 2, 0, 0, 0, 0)
        Citizen.Wait(6000)
        oyuncukelepceledi = false
        ClearPedTasksImmediately(playerPed)
    end)
end) 

-- Kelepçeli Oyuncuyu Taşı
RegisterNetEvent("mdt-kelepce:tasi")
AddEventHandler("mdt-kelepce:tasi", function()
    if sistemAktif then
        local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 1.5 then
            local targetPlayerPed = GetPlayerServerId(closestPlayer) 
            QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                if data.pkelepce or data.kelepce then
                    TriggerServerEvent("mdt-kelepce:tasi-target-server", targetPlayerPed)
                end
            end, targetPlayerPed) 
        end  
    end
end)

RegisterNetEvent('mdt-kelepce:tasi-target-client')
AddEventHandler('mdt-kelepce:tasi-target-client', function(copId)
    dragStatus.isDragged = not dragStatus.isDragged
    dragStatus.CopId = copId
    
    local playerPed = PlayerPedId()
    if dragStatus.isDragged then
        targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

        if not IsPedSittingInAnyVehicle(targetPed) then
            AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        else
            dragStatus.isDragged = false
            DetachEntity(playerPed, true, false)
        end

        if IsPedDeadOrDying(targetPed, true) then
            dragStatus.isDragged = false
            DetachEntity(playerPed, true, false)
        end
    else
        DetachEntity(playerPed, true, false)
    end
end)

-- Araç İçine Koyma
RegisterNetEvent("mdt-kelepce:arac")
AddEventHandler("mdt-kelepce:arac", function()
    if sistemAktif then
        local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            local targetPlayerPed = GetPlayerServerId(closestPlayer)
            QBCore.Functions.TriggerCallback('mdt-kelepce:target-kelepcelimi', function(data)
                if data.pkelepce or data.kelepce then
                    TriggerServerEvent("mdt-kelepce:arac-ici-koy-server", targetPlayerPed, "normal")
                end
            end, targetPlayerPed) 
        end  
    end
end)

RegisterNetEvent('mdt-kelepce:arac-ici-koy-client')
AddEventHandler('mdt-kelepce:arac-ici-koy-client', function(type)
    if (type == "dead" and isDead) or (type == "normal" and not isDead) then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        if not IsPedSittingInAnyVehicle(playerPed) then
            local arac, akordinat = QBCore.Functions.GetClosestVehicle(coords)
            if akordinat < 5 then
                if DoesEntityExist(arac) then
                    local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(arac)

                    for i=maxSeats - 1, 0, -1 do
                        if IsVehicleSeatFree(arac, i) then
                            freeSeat = i
                            break
                        end
                    end

                    if freeSeat then
                        TriggerEvent("mdt-kucak:yaralibindir")
                        TaskWarpPedIntoVehicle(playerPed, arac, freeSeat)
                        dragStatus.isDragged = false
                    end
                end
            end
        else
            ClearPedSecondaryTask(playerPed)
            SetEntityCoords(playerPed, coords.x, coords.y, coords.z + 1)
        end
    end
end)

-- Chat Komutları
RegisterNetEvent("mdt-kelepce:client:tasi")
AddEventHandler("mdt-kelepce:client:tasi", function()
    TriggerEvent("mdt-kelepce:tasi")
end) 

RegisterNetEvent("mdt-kelepce:client:arac")
AddEventHandler("mdt-kelepce:client:arac", function()
    TriggerEvent("mdt-kelepce:arac")
end) 

RegisterNetEvent("mdt-kelepce:client:ybindir")
AddEventHandler("mdt-kelepce:client:ybindir", function()
    if sistemAktif then
        local playerPed = PlayerPedId()
        if not IsPedInAnyVehicle(playerPed) then
            local closestPlayer, closestDistance = QBCore.Functions.GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                ClearPedSecondaryTask(playerPed)
                TriggerServerEvent("mdt-kelepce:arac-ici-koy-server", GetPlayerServerId(closestPlayer), "dead") 
            end 
        else
          QBCore.Functions.Notify("Araç İçindeki İken Bu İşlemi Gerçekleştiremezsin") 
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        local time = 1000
        if poliskelepceledi or oyuncukelepceledi then
            time = 1
            local playerPed = PlayerPedId()
            DisablePlayerFiring(playerPed, true)

            DisableControlAction(0,21,true) -- disable sprint
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 37, true) -- Select Weapon

            DisableControlAction(0, 56, true) -- F9
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover

            DisableControlAction(0, 288, true) --F1
            DisableControlAction(0, 289, true) -- F2
            DisableControlAction(0, 170, true) -- F3
            DisableControlAction(0, 167, true) -- F6

            DisableControlAction(0, 26, true) -- Disable looking behind
            DisableControlAction(0, 73, true) -- Disable clearing animation

            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle
			DisableControlAction(2, 21, true) -- Disable going stealth

            DisableControlAction(0, 47, true)  -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true)  -- Disable exit vehicle
            DisableControlAction(0, 301, true)  -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle
            DisableControlAction(0, 23, true)
        end
        Citizen.Wait(time)
    end
end)

function mansetSound()
    Citizen.Wait(700)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 1.5, 'uncuff', 1.0)
end

function kelepceSound()
    Citizen.Wait(100)
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 1.5, 'handcuff', 1.0)
end

function kordinat()
    playerheading = GetEntityHeading(playerPed)
    playerlocation = GetEntityForwardVector(playerPed)
    playerCoords = GetEntityCoords(playerPed)
end
--[[
function konumaldir(playerPed, playerlocation, playerheading, playerCoords)
    SetCurrentPedWeapon(playerPed, 'WEAPON_UNARMED', true) -- unarm player
    local x, y, z = table.unpack(playerCoords + playerlocation * 0.95)
    SetEntityCoords(PlayerPedId(), x, y, z - 1.0)
    SetEntityHeading(PlayerPedId(), playerheading)
end 
--]]
