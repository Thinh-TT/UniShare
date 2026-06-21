using FluentValidation;
using UniShare.API.Models.DTOs.Auth;

namespace UniShare.API.Validators.Auth;

public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Invalid email format")
            .MaximumLength(256).WithMessage("Email must not exceed 256 characters");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required")
            .MinimumLength(8).WithMessage("Password must be at least 8 characters")
            .MaximumLength(100).WithMessage("Password must not exceed 100 characters")
            .Matches(@"[A-Z]").WithMessage("Password must contain at least one uppercase letter")
            .Matches(@"[a-z]").WithMessage("Password must contain at least one lowercase letter")
            .Matches(@"\d").WithMessage("Password must contain at least one digit")
            .Matches(@"[!@#$%^&*(),.?"":{}|<>]").WithMessage("Password must contain at least one special character");

        RuleFor(x => x.FullName)
            .NotEmpty().WithMessage("Full name is required")
            .MaximumLength(150).WithMessage("Full name must not exceed 150 characters")
            .Matches(@"^[\p{L}\s]+$").WithMessage("Full name must only contain letters and spaces");

        RuleFor(x => x.PhoneNumber)
            .MaximumLength(20)
            .Matches(@"^\+?[0-9\s\-]{8,20}$")
            .When(x => !string.IsNullOrEmpty(x.PhoneNumber))
            .WithMessage("Invalid phone number format");
    }
}
