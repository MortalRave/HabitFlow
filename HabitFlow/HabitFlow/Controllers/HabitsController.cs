using HabitFlow.Data;
using HabitFlow.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace HabitFlow.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HabitsController : ControllerBase
{
    private readonly AppDbContext _context;

    public HabitsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Habit>>> GetHabits()
    {
        var habits = await _context.Habits.ToListAsync();
        return Ok(habits);
    }

    [HttpPost]
    public async Task<ActionResult<Habit>> CreateHabit(Habit habit)
    {
        _context.Habits.Add(habit);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetHabits), new { id = habit.Id }, habit);
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteHabit(int id)
    {
        var habit = await _context.Habits.FindAsync(id);

        if (habit == null) return NotFound();

        _context.Habits.Remove(habit);
        await _context.SaveChangesAsync();

        return NoContent();

    }

    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateHabit(int id, Habit updatedHabit)
    {
        if (id != updatedHabit.Id) return BadRequest();

        var existingHabit = await _context.Habits.FindAsync(id);
        if (existingHabit == null) return NotFound();

        existingHabit.Name = updatedHabit.Name;
        existingHabit.Description = updatedHabit.Description;
        existingHabit.StreakCount = updatedHabit.StreakCount;

        await _context.SaveChangesAsync();

        return NoContent();
    }

    [HttpPost("{id}/complete")]
    public async Task<ActionResult> MarkAsCompleted(int id)
    {
        var habit = await _context.Habits.FindAsync(id);
        if (habit == null) return NotFound();

        bool success = habit.MarkAsCompleted();
        if (!success) return BadRequest("This habit has been done today!");
        await _context.SaveChangesAsync();

        return Ok(habit);
    }
}