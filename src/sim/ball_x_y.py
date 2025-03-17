# Re-import necessary libraries after execution state reset
import matplotlib.pyplot as plt

# Example ball trajectory (X, Y) coordinates when it hits a wall
ball_trajectory = [
    (397, 297),
    (702, 598),
    (798, 498),
    (298, 2),
    (28, 272),
    (776, 272),
    (45, 272),
]

# Screen dimensions
screen_width = 800
screen_height = 600

# Player attributes
player_width = 10
player_height = 100  # Full player height
player_x_padding = 20
player1_y_position = 290
player2_y_position = 310

# Player positions
player1_x = player_x_padding
player2_x = screen_width - player_x_padding - player_width

# Number of segments for player
segments = 5
segment_height = player_height // segments

# Extract X and Y values
x_values = [point[0] for point in ball_trajectory]
y_values = [point[1] for point in ball_trajectory]

# Create plot
plt.figure(figsize=(8, 6))
plt.plot(
    x_values, y_values, "o-", label="Ball Movement", markersize=8, color="blue"
)  # Plot points & lines

# Add Player 1 Segments
for i in range(segments):
    plt.gca().add_patch(
        plt.Rectangle(
            (player1_x, player1_y_position - player_height // 2 + i * segment_height),
            player_width,
            segment_height,
            color="red" if i % 2 == 0 else "darkred",
            label="Player 1" if i == 0 else "",
        )
    )

# Add Player 2 Segments
for i in range(segments):
    plt.gca().add_patch(
        plt.Rectangle(
            (player2_x, player2_y_position - player_height // 2 + i * segment_height),
            player_width,
            segment_height,
            color="green" if i % 2 == 0 else "darkgreen",
            label="Player 2" if i == 0 else "",
        )
    )

# Set screen dimensions and invert Y-axis scale
plt.xlim(0, 800)
plt.ylim(0, 600)
plt.gca().invert_yaxis()  # Invert Y-axis labels to match the flipped values

# Labels and Title
plt.xlabel("X Position (Pixels)")
plt.ylabel("Y Position (Pixels)")
plt.title("Ball Trajectory with Segmented Players on 800x600 Screen")
plt.legend()
plt.grid()

# Show the plot
plt.show()
