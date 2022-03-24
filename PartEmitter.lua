local CFramenew = CFrame.new
local RunService = game:GetService("RunService")


local BasepartEmitter = {}

local EmitterList = {}

local function Stepped(runTime,deltaTime)
	for _, Emitter in ipairs(EmitterList) do
		Emitter.TimePosition += deltaTime
		if Emitter.TimePosition > Emitter.Info.Lifetime then
			Emitter.TimePosition -= Emitter.Info.Lifetime	
			local CurrentParticle = Emitter.Clones[Emitter.Current]	
			if not CurrentParticle then
				warn("Particles are being deleted. Make sure particles are not deleted to avoid lag")
				local tempClone = Emitter.Info.Basepart:Clone()
				tempClone.CFrame = Emitter.Info.Origin.CFrame
				tempClone.AssemblyLinearVelocity = Emitter.Velocity
				Emitter.Clones[Emitter.Current] = tempClone
				tempClone.Parent = Emitter.Info.Parent
			elseif CurrentParticle.Parent == nil then
				CurrentParticle.Parent = workspace
			else
				Emitter.ParticleReset:Fire(CurrentParticle)
			end
			CurrentParticle.CFrame = Emitter.Info.Origin.CFrame
			CurrentParticle.AssemblyLinearVelocity = Emitter.Info.Velocity
			Emitter.Current += 1
			if Emitter.Current > Emitter.Info.ParticleAmount then
				Emitter.Current = 1
			end
		end
	end
end

function BasepartEmitter.new(Basepart: BasePart?, Origin: BasePart? | Attachment?, ParticleAmount: number?, Lifetime: number?)
	local Emitter = {
		Basepart	= Basepart or Instance.new("Part");
		ParticleAmount  = ParticleAmount or 10;
		Lifetime	= Lifetime or 2;		-- Lifetime controls rate
		Enabled 	= true;
		Origin		= Origin or workspace:FindFirstChildWhichIsA("Terrain");
		Parent 		= workspace;
		Velocity	= Vector3.new()
	}
	local EmitterMetatable = {
		_newindex = function()
			warn("Tried to add property to object.")
		end;
		_index = function(Table, index)
			print("Indexed")
		end
	}
	local Clones = {}
	
	local ParticleResetEvent = Instance.new("BindableEvent")
	Emitter.ParticleReset = ParticleResetEvent.Event
	
	
	for i = 1, Emitter.ParticleAmount do
		local BasepartClone = Emitter.Basepart:Clone()
		
		BasepartClone.CFrame = Emitter.Origin.CFrame
		BasepartClone.AssemblyLinearVelocity = Vector3.new()
		table.insert(Clones,BasepartClone)
	end
	setmetatable(Emitter,EmitterMetatable)
	
	table.insert(EmitterList,{
		Info			= Emitter;
		Metatable		= EmitterMetatable;
		TimePosition	= 0;
		Current			= 1;
		Clones 			= Clones;
		ParticleReset	= ParticleResetEvent;
		}
	)
	return Emitter
end


RunService.Stepped:Connect(Stepped)

return BasepartEmitter
