using Godot;
using System;
using System.Linq;

/// <summary>Base class for all entities</summary>
public class Entity : StaticBody2D
{
    // ===================== VARIABLES =====================

    protected bool Configured;
    protected bool Initialized;

    // rotation stuff
    public enum RotationMode
    {
        UP,
        RIGHT,
        DOWN,
        LEFT
    }
    protected const RotationMode defaultRotation = RotationMode.DOWN;
    public new RotationMode Rotation = defaultRotation;

    protected TileMap ParentTileMap;
    public AnimatedSprite AnimatedSprite = new AnimatedSprite();
    public int Frame
    {
        set { AnimatedSprite.Frame = value; }
        get { return AnimatedSprite.Frame; }
    }
    public bool SyncAnimation;

    //public CollisionShape2D CollisionShape2D = new CollisionShape2D();
    //public Shape2D CollisionShape
    //{
    //    set { CollisionShape2D.Shape = value; }
    //    get { return CollisionShape2D.Shape; }
    //}

    public Vector2 Coordinates
    {
        set {
            if (!Initialized) WError("Cannot set Coordinates of uninitialized Entity"); 
            else Position = (ParentTileMap.MapToWorld(value) + ParentTileMap.CellSize / 2f) * ParentTileMap.Scale;
        }
        get {
            if (!Initialized) { WError("Cannot set Coordinates of uninitialized Entity"); return new Vector2(0, 0); }
            return ParentTileMap.WorldToMap(Position / ParentTileMap.Scale - ParentTileMap.CellSize / 2f);
        }
    }

    // ===================== CONFIGS =====================

    //public void ConfigSimpleEntity(Shape2D collider, string spritePath)
    public void ConfigSimpleEntity(string spritePath)
    {
        StreamTexture streamText = GD.Load<StreamTexture>(spritePath);
        SpriteFrames frames = new SpriteFrames();
        frames.AddFrame("default", streamText, 0);

        //Config(collider, frames);
        Config(frames);
    }

    //public void ConfigAnimatedEntity(Shape2D collider, string spriteSheetPath, int[] spriteCount, float speed)
    public void ConfigAnimatedEntity(string spriteSheetPath, int[] spriteCount, float speed, bool synced = true)
    {
        // assert that spriteCount's length is 2
        if (spriteCount.Length != 2) WError("Invalid spriteCount dimensions, expected an array of 2 integers");

        StreamTexture streamText = GD.Load<StreamTexture>(spriteSheetPath);
        SpriteFrames frames = new SpriteFrames();

        // first splice the streamText up as per the spriteCount using AtlasTextures
        float width  = (float)streamText.GetWidth()  / spriteCount[0];
        float height = (float)streamText.GetHeight() / spriteCount[1];

        int index = 0;
        for(int y = 0; y < spriteCount[1]; y++)
            for(int x = 0; x < spriteCount[0]; x++)
            {
                AtlasTexture atlas = new AtlasTexture
                {
                    Atlas = streamText,
                    Region = new Rect2
                    {
                        Position = new Vector2(x * width, y * height),
                        Size = new Vector2(width, height)
                    }
                };
                frames.AddFrame("default", atlas, index);
                index++;
            }

        frames.SetAnimationLoop("default", true);
        //frames.SetAnimationSpeed("default", fps);
        AnimatedSprite.SpeedScale = speed;
        AnimatedSprite.Playing = true;

        SyncAnimation = synced;

        //Config(collider, frames);
        Config(frames);
    }

    // ===================== FUNCTIONS =====================

    //public void Config(Shape2D collider, SpriteFrames frames)
    public void Config(SpriteFrames frames)
    {
        //CollisionShape = collider;
        AnimatedSprite.Frames = frames;

        Configured = true;
    }

    public void Init(TileMap map)
    {
        ParentTileMap = map;
        Scale = ParentTileMap.Scale;
        Name = GetType().Name;

        Initialized = true;
    }

    public override void _Ready()
    {
        if (!Configured) WError("Entity not configured", false);
        if (!Initialized) WError("Entity not initialized");

        AddChild(AnimatedSprite);
        //AddChild(CollisionShape2D);

        AddToGroup(GetType().Name);
    }

    
    public override void _PhysicsProcess(float delta)
    {
        if (SyncAnimation)
            AnimatedSprite.Frame = ((Entity)GetTree().GetNodesInGroup(GetType().Name)[0]).Frame;
    }

    public void Delete()
    {
        QueueFree();
    }

    public void Rotate(bool right)
    {
        RotationMode max = Enum.GetValues(typeof(RotationMode)).Cast<RotationMode>().Last();
        if (right) Rotation = Rotation + 1 > max ? 0 : Rotation + 1;
        else Rotation = Rotation - 1 < 0 ? max: Rotation - 1;
    }

    public override string ToString()
    {
        return $"[{GetType().Name}:{GetInstanceId()}]";
    }

    protected void WError(string message, bool exception = true)
    {
        string function = (new System.Diagnostics.StackTrace()).GetFrame(1).GetMethod().Name;
        string detail = exception ? "thrown" : "warning";
        string msg = $"[{GetType().Name}:{GetInstanceId()}]:{function}(): {message} ({detail})";
        GD.PrintErr(msg);
        if(exception) throw new ApplicationException(msg);
    }
}
