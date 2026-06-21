using FluentValidation;
using UniShare.API.Models.DTOs.Interactions;

namespace UniShare.API.Validators.Interactions;

public class UpdateCommentRequestValidator : AbstractValidator<UpdateCommentRequest>
{
    public UpdateCommentRequestValidator()
    {
        RuleFor(x => x.Content)
            .NotEmpty().WithMessage("Comment content is required")
            .MaximumLength(1000).WithMessage("Comment content must not exceed 1000 characters");
    }
}
