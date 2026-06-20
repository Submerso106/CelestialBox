export type Orbit = {
    Center: Vector3,
    Angle: CFrame,
    Distance: number,
    ShapeFactor: Vector3,
    
    PositionFromTime: (self: Orbit, body: Body, returnAsRad: boolean?) -> number
}

export type Body = {
	Orbit: Orbit?,
    OrbitStart: number?,
    OrbitAnglePerSecond: CFrame?,
    Rotation: CFrame,
    Angle: CFrame,
    Color: Color3,
    DaySize: number,
    YearSize: number,

    Display: ViewportFrame,
    Model: Model,

    UpdateInfo: (self: Body) -> (),
}

export type Instance = {
    Name: string,
    Time: number,
    TickPerSecond: number,
    TimePerSecond: number,
    TimePerTick: number,
    Bodies: {[Model]: Body},
    Standing: Body?,
}

return nil