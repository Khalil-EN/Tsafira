function UserPreviewDTO(user) {
  if (!user) return null;

  return {
    id: user._id,
    fullName: `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim(),
    profilePicture: user.profilePicture ?? null,
  };
}

module.exports = { UserPreviewDTO };