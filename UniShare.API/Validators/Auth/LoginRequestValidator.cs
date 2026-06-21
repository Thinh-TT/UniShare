using FluentValidation;
using UniShare.API.Models.DTOs.Auth;

namespace UniShare.API.Validators.Auth;

public class LoginRequestValidator : AbstractValidator<LoginRequest>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Login)
            .NotEmpty().WithMessage("Email or phone number is required")
            .MaximumLength(256).WithMessage("Login must not exceed 256 characters");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required");
    }
}
