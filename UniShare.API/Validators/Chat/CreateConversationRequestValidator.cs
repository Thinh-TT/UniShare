using FluentValidation;
using UniShare.API.Models.DTOs.Chat;

namespace UniShare.API.Validators.Chat;

public class CreateConversationRequestValidator : AbstractValidator<CreateConversationRequest>
{
    public CreateConversationRequestValidator()
    {
        RuleFor(x => x.InitialMessage)
            .MaximumLength(2000)
            .WithMessage("Initial message must not exceed 2000 characters")
            .When(x => x.InitialMessage is not null);
    }
}
