QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterServerEvent('mdt-kelepce:polis-kelepce-tak-takilan')
AddEventHandler('mdt-kelepce:polis-kelepce-tak-takilan', function(targetPlayerPed, playerlocation, playerheading, playerCoords)
	local polis = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)
	Oyuncu.Functions.SetMetaData("kelepceli", true)
	TriggerClientEvent('mdt-kelepce:polis-kelepce-tak-yakin-oyuncu-client', Oyuncu.PlayerData.source, playerlocation, playerheading, playerCoords, polis)
end)

RegisterServerEvent('mdt-kelepce:anim-cancel')
AddEventHandler('mdt-kelepce:anim-cancel', function(targetid, tip)
	TriggerClientEvent('mdt-kelepce:client:anim-cancel', targetid)
end)

RegisterServerEvent('mdt-kelepce:polis-kelepce-coz-takilan')
AddEventHandler('mdt-kelepce:polis-kelepce-coz-takilan', function(targetPlayerPed, playerlocation, playerheading, playerCoords)
	local polis = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)
	Oyuncu.Functions.SetMetaData("kelepceli", false)
	TriggerClientEvent('mdt-kelepce:polis-kelepce-coz-yakin-oyuncu-client', Oyuncu.PlayerData.source, playerlocation, playerheading, playerCoords)
end)


RegisterServerEvent('mdt-kelepce:kelepce-tak-takilan')
AddEventHandler('mdt-kelepce:kelepce-tak-takilan', function(targetPlayerPed, playerlocation, playerheading, playerCoords)
	local takan = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)
	Oyuncu.Functions.SetMetaData("kelepcelinormal", true)
	TriggerClientEvent('mdt-kelepce:kelepce-tak-yakin-oyuncu-client', Oyuncu.PlayerData.source, playerlocation, playerheading, playerCoords, takan)
end)

RegisterServerEvent('mdt-kelepce:kelepce-coz-takilan')
AddEventHandler('mdt-kelepce:kelepce-coz-takilan', function(targetPlayerPed, playerlocation, playerheading, playerCoords)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)
	Oyuncu.Functions.SetMetaData("kelepcelinormal", false)
	TriggerClientEvent('mdt-kelepce:kelepce-coz-yakin-oyuncu-client', Oyuncu.PlayerData.source, playerlocation, playerheading, playerCoords)
end)

RegisterServerEvent('mdt-kelepce:kelepce-coz-takilan')
AddEventHandler('mdt-kelepce:kelepce-coz-takilan', function(targetPlayerPed)
	local polis = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)

	TriggerClientEvent('mdt-kelepce:tasi-target-client', Oyuncu.PlayerData.source, polis)
end)

RegisterServerEvent('mdt-kelepce:arac-ici-koy-server')
AddEventHandler('mdt-kelepce:arac-ici-koy-server', function(targetPlayerPed, tip)
	local polis = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)

	TriggerClientEvent('mdt-kelepce:arac-ici-koy-client', Oyuncu.PlayerData.source, tip)
end)

RegisterServerEvent('mdt-kelepce:tasi-target-server')
AddEventHandler('mdt-kelepce:tasi-target-server', function(targetPlayerPed)
	local polis = QBCore.Functions.GetPlayer(source)
	local Oyuncu = QBCore.Functions.GetPlayer(targetPlayerPed)

	TriggerClientEvent('mdt-kelepce:tasi-target-client', Oyuncu.PlayerData.source, polis.PlayerData.source)
end)

QBCore.Functions.CreateCallback('mdt-kelepce:target-kelepcelimi', function(source, cb, targetPlayerPed)
	local target = QBCore.Functions.GetPlayer(targetPlayerPed)

	local data =  {
		pkelepce = target.PlayerData.metadata['kelepceli'],
		kelepce = target.PlayerData.metadata['kelepcelinormal'],
	}

	cb(data)
end)

QBCore.Functions.CreateUseableItem("kelepce", function(source, item)
    TriggerClientEvent("mdt-kelepce:kelepce-tak-client", source)
end)

QBCore.Functions.CreateUseableItem("kelepceanahtar", function(source, item)
    TriggerClientEvent("mdt-kelepce:kelepce-coz-client", source)
end)

QBCore.Functions.CreateUseableItem("pkelepce", function(source, item)
	TriggerEvent('mdt-kelepce:polis-kelepce-tak-client')
end)

QBCore.Functions.CreateUseableItem("pkelepceanahtar", function(source, item)
	TriggerEvent('mdt-kelepce:polis-kelepce-coz-client')
end)

