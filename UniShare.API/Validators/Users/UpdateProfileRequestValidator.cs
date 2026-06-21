using FluentValidation;
using UniShare.API.Models.DTOs.Users;

namespace UniShare.API.Validators.Users;

public class UpdateProfileRequestValidator : AbstractValidator<UpdateProfileRequest>
{
    public UpdateProfileRequestValidator()
    {
        RuleFor(x => x.FullName)
            .MaximumLength(150).WithMessage("Full name must not exceed 150 characters")
            .Matches(@"^[\p{L}\s]+$")
            .When(x => !string.IsNullOrEmpty(x.FullName))
            .WithMessage("Full name must only contain letters and spaces");

        RuleFor(x => x.PhoneNumber)
            .MaximumLength(20)
            .Matches(@"^\+?[0-9\s\-]{8,20}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Invalid phone number format");

        RuleFor(x => x.AvatarUrl)
            .MaximumLength(500).WithMessage("Avatar URL must not exceed 500 characters")
            .Must(uri => Uri.TryCreate(uri, UriKind.Absolute, out _))
            .When(x => !string.IsNullOrEmpty(x.AvatarUrl))
            .WithMessage("Avatar URL must be a valid URL");
    }
}
