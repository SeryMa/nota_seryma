function getInfo()
    return {
        onNoUnits = SUCCESS, -- instant success
        tooltip = "Get ifno unit in param",
        parameterDefs = {
            { 
                name = "lineName",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "GoodMiddle",
            },
            { 
                name = "upgradeLevel",
                variableType = "expression",
                componentType = "editBox",
                defaultValue = "1",
            },
        }
    }
end

-- get madatory module operators
VFS.Include("modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load

function Run(self, units, parameter)
    message.SendRules({
        subject = "swampdota_upgradeLine",
        data = {
            lineName = parameter.lineName,
            upgradeLevel = parameter.upgradeLevel,
        },
    })

    return SUCCESS
end


function Reset(self)
    return self
end