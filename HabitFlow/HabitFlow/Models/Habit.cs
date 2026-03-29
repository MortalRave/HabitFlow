namespace HabitFlow.Models;

using System;

public class Habit
{
	// Basic data types
	public int Id { get; set; }
	public string Name { get; set; } = string.Empty;
	public string Description { get; set; } = string.Empty;
	public DateTime CreatedDate { get; set; } = DateTime.Now;
	// Statistics and logic
	public int StreakCount { get; set; } = 0;
	public DateTime? LastCompletedDate { get; set; }
	public bool IsCompletedToday { get; set; }

	public Habit()
	{
	}

}
