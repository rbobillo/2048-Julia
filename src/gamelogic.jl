include("utils.jl")

using Match
using SplitApplyCombine

cleanrow(row) = row |> dropzeros |> lpadrow

merge_row(row) = cleanrow(@match cleanrow(row) begin
    [a,b,c,d], if a ≠ b ≠ c ≡ d end => [a,b,c+d] # [a,b,c,c]
    [a,b,c,d], if a ≠ b ≡ c ≡ d end => [a,b,c+d] # [a,b,b,b]
    [a,b,c,d], if a ≠ b ≡ c ≠ d end => [a,b+c,d] # [a,b,b,c]
    [a,b,c,d], if a ≡ b ≠ c ≡ d end => [a+b,c+d] # [a,a,b,b]
    [a,b,c,d], if a ≡ b ≡ c ≡ d end => [a+b,c+d] # [a,a,a,a]
    [a,b,c,d], if a ≡ b ≡ c ≠ d end => [a,b+c,d] # [a,a,a,b]
    [a,b,c,d], if a ≡ b ≠ c ≠ d end => [a+b,c,d] # [a,a,b,c]
    xs                              => xs
end)

merge_r(board) = [merge_row(row) for row in board]

merge_l(board) = [reverse(merge_row(reverse(r))) for r in board]

merge_d(board) = invert(merge_r(invert(board)))

merge_u(board) = invert(merge_l(invert(board)))

isplayable(board) =
    board ≠ (board |> merge_r |> merge_l |> merge_d |> merge_u)

function merge(direction, board) =
    "merge_$(direction)(board)" |> evalfunctioncall |>
        nextboard -> isplayable(nextboard) ? nextboard : nothing