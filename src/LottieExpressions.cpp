/*
 * Copyright (c) 2024 - 2026 ThorVG project. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "Example.h"

 /************************************************************************/
 /* ThorVG Drawing Contents                                              */
 /************************************************************************/

#define NUM_PER_ROW 6
#define NUM_PER_COL 6

struct UserExample : tvgexam::Example
{
	std::vector<unique_ptr<tvg::Animation>> animations;
	uint32_t w, h;
	uint32_t size;
	tvg::Canvas* _canvas = nullptr;

	int counter = 0;
	bool loaded = false;
	uint32_t toggleTime = 0;
	int cycle = 0;

	void populate(const char* path) override
	{
		if (counter >= NUM_PER_ROW * NUM_PER_COL) return;

		//ignore if not lottie.
		const char* ext = path + strlen(path) - 4;
		if (strcmp(ext, "json") && strcmp(ext, "lot")) return;

		//Animation Controller
		auto animation = tvg::Animation::gen();
		auto picture = animation->picture();
		picture->origin(0.5f, 0.5f);

		if (!tvgexam::verify(picture->load(path))) return;

		//image scaling preserving its aspect ratio
		float w, h;
		picture->size(&w, &h);
		picture->scale((w > h) ? size / w : size / h);
		picture->translate((counter % NUM_PER_ROW) * size + size / 2, (counter / NUM_PER_ROW) * (this->h / NUM_PER_COL) + size / 2);

		animations.push_back(unique_ptr<tvg::Animation>(animation));

		cout << "Lottie: " << path << endl;

		counter++;
	}

	void loadAnimations()
	{
		counter = 0;
		this->scandir(EXAMPLE_DIR"/lottie/expressions");

		for (auto& animation : animations) {
			_canvas->add(animation->picture());
		}

		loaded = true;
		cout << "[Cycle " << cycle << "] Loaded " << animations.size() << " animations" << endl;
	}

	void unloadAnimations()
	{
		for (auto& animation : animations) {
			_canvas->remove(animation->picture());
		}
		animations.clear();

		loaded = false;
		cout << "[Cycle " << cycle << "] Unloaded all animations" << endl;
		cycle++;
	}

	bool update(tvg::Canvas* canvas, uint32_t elapsed) override
	{
		//toggle every 5 seconds
		// if (elapsed - toggleTime >= 5000) {
		//     toggleTime = elapsed;
		//     if (loaded) unloadAnimations();
		//     else loadAnimations();
		// }

		for (auto& animation : animations) {
			auto progress = tvgexam::progress(elapsed, animation->duration());
			animation->frame(animation->totalFrame() * progress);
		}
		////toggle every 5 seconds
		//if (elapsed - toggleTime >= 1000) {
		//	toggleTime = elapsed;
		//	if (loaded) unloadAnimations();
		//	else loadAnimations();
		//}
		canvas->update();

		return true;
	}

	bool content(tvg::Canvas* canvas, uint32_t w, uint32_t h) override
	{
		_canvas = canvas;

		//The default font for fallback in case
		tvg::Text::load(EXAMPLE_DIR"/font/PublicSans-Regular.ttf");

		//Background
		auto shape = tvg::Shape::gen();
		shape->appendRect(0, 0, w, h);
		shape->fill(75, 75, 75);

		canvas->add(shape);

		this->w = w;
		this->h = h;
		this->size = w / NUM_PER_ROW;

		loadAnimations();

		return true;
	}
};


/************************************************************************/
/* Entry Point                                                          */
/************************************************************************/

int main(int argc, char** argv)
{
	int threadcnt = 0;
	if (argc > 2) {
		threadcnt = atoi(argv[2]);
	}
	return tvgexam::main(new UserExample, argc, argv, false, 1024, 1024, threadcnt, true);
}