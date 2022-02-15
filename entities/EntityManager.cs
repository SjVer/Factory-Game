using System.Collections.Generic;
using System.Linq;
using System;
using Godot;

/// <summary>Manager of entities</summary>
public class EntityManager : Godot.Object
{
    private Dictionary<Godot.Vector2, Entity> Entities = new Dictionary<Vector2, Entity>();
    //private List<Entity> Entities = new List<Entity>();

    #region Creators
    public Entity CreateNewEntity(string className, params object[] args)
    {
        try
        {
            System.Reflection.Assembly assembly = System.Reflection.Assembly.GetExecutingAssembly();
            Type type = assembly.GetTypes().First(t => t.Name == className);

            if (type != typeof(Entity) && !type.IsSubclassOf(typeof(Entity)))
            {
                WError($"Class \"{className}\" is no subclass of Entity. {type != typeof(Entity)} {!type.IsSubclassOf(typeof(Entity))}");
                return null;
            }

            Entity entity = (Entity)Activator.CreateInstance(type, args);
            return entity;
        }
        catch (Exception ex)
        {
            WError($"Failed to create Entity of class \"{className}\" with arguments {{{args}}}: {ex}", true);
            return null;
        }
    }

    #endregion

    #region EntityOps
    public bool EntityAt(Vector2 position)
    {
        return Entities.ContainsKey(position);
    }

    public void SetEntity(Entity entity, Vector2 position)
    {
        if (EntityAt(position))
            WError($"Replaced entity {Entities[position]} at {position}.", false);
        Entities[position] = entity;
    }

    public Entity GetEntity(Vector2 position)
    {
        if(!EntityAt(position))
        {
            WError($"Cannot get non-existent entity at {position}.");
            return null;
        }
        return Entities[position];
    }

    public Entity RemoveEntity(Vector2 position)
    {
        if (!EntityAt(position))
        {
            WError($"Removed non-existend entity at {position}.", false);
            return null;
        }

        Entity entity = Entities[position];
        Entities.Remove(position);
        return entity;
    }
    #endregion

    protected void WError(string message, bool exception = true)
    {
        string function = (new System.Diagnostics.StackTrace()).GetFrame(1).GetMethod().Name;
        string detail = exception ? "thrown" : "warning";
        string msg = $"[{GetType().Name}]:{function}(): {message} ({detail})";
        GD.PrintErr(msg);
        if (exception) throw new ApplicationException(msg);
    }
}