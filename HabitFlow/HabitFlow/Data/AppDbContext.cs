using HabitFlow.Models;
using Microsoft.EntityFrameworkCore;

namespace HabitFlow.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }
        public DbSet<Habit> Habits { get; set; }
    }
}
