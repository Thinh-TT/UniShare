using FluentValidation;
using UniShare.API.Models.DTOs.Chat;

namespace UniShare.API.Validators.Chat;

public class SendMessageRequestValidator : AbstractValidator<SendMessageRequest>
{
    public SendMessageRequestValidator()
    {
        RuleFor(x => x.Content)
            .NotEmpty()
            .WithMessage("Message content is required")
            .MaximumLength(2000)
            .WithMessage("Message content must not exceed 2000 characters");
    }
}
