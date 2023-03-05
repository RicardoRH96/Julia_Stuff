begin
	using Tidier
	using RDatasets
end

movies = RDatasets.dataset("ggplot2","movies")

high_budget = @chain movies begin
	@mutate(Budget= Budget / 1_000_000)
	@filter(Budget >= mean(skipmissing(Budget)), Year > 2000)
	@select(Title, Year, Budget, Rating)
    @slice(1:100)
end
	
using DataFrames

sorted_hb=sort(high_budget, :Rating, rev=true)
using PlotlyJS, CSV, WebIO

function make_hover_text(row)
    join([
        "Title: $(row.Title)<br>",
        "Year: $(row.Year)<br>",
        "Budget: $(row.Budget)<br>",
        "Rating: $(row.Rating)<br>"
    ], " ")
end

p = plot(sorted_hb, x=:Budget, y=:Rating, color=:Year , mode="markers",
    text=sub_df -> make_hover_text.(DataFrames.eachrow(sub_df)),
    marker=attr(size=:Budget, sizeref=2*maximum(sorted_hb.Rating) / (30^2), sizemode="area"),
    Layout(
        title="Movies Budget vs Rating",
        xaxis=attr(
            title_text="Movie Budget (in Million Dollars)",
            gridcolor="white"
        ),
        yaxis=attr(title_text="Rating", gridcolor="white"),
        paper_bgcolor="rgb(243, 243, 243)",
        plot_bgcolor="rgb(243, 243, 243)",
    ))

open("./example.html", "w") do io
        PlotlyBase.to_html(io, p.plot)
    end

savefig(p.plot, "bubble.png", width=1800, height=900)