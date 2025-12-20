# 🍽️ Restaurant Finder

A Next.js application for finding restaurants near you. This project serves as a foundation for an AI-assisted coding workshop.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Run the development server
npm run dev

# Open http://localhost:3000 in your browser
```

## 📋 Features

- **Location Search**: Enter an address, city, or zip code to find nearby restaurants
- **Mock Data**: 25 restaurants in the San Francisco area
- **Distance Calculation**: Restaurants sorted by proximity using the Haversine formula
- **Responsive Design**: Works on desktop and mobile devices

## 🛠️ Tech Stack

- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Testing**: Jest + React Testing Library
- **Linting**: ESLint + Prettier

## 📁 Project Structure

```
restaurant-finder/
├── app/
│   ├── api/
│   │   └── restaurants/
│   │       ├── route.ts          # Main API endpoint
│   │       └── favorites/
│   │           └── route.ts      # Favorites endpoint (unused)
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── RestaurantCard.tsx
│   ├── RestaurantMap.tsx         # Legacy component (unused)
│   └── SearchForm.tsx
├── data/
│   └── restaurants.json          # Mock restaurant data
├── types/
│   └── restaurant.ts
├── utils/
│   ├── distance.ts               # Distance calculations
│   └── helpers.ts                # Helper utilities (some unused)
└── __tests__/
    ├── api/
    ├── components/
    └── utils/
```

## 📝 Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Fix ESLint errors |
| `npm run format` | Format code with Prettier |
| `npm run test` | Run tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:coverage` | Run tests with coverage |

## 🎯 Workshop Exercises

TODO: Please ask your instructors for the document link.

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env.local` and configure:

```bash
cp .env.example .env.local
```

### API Endpoints (this one is provided, you'll be building more in the workshop)

#### GET /api/restaurants

Find restaurants near a location.

**Query Parameters:**
- `address` (string): Address to search near
- `lat` (number): Latitude coordinate
- `lng` (number): Longitude coordinate

**Example:**
```bash
curl "http://localhost:3000/api/restaurants?address=San%20Francisco"
```

**Response:**
```json
{
  "restaurants": [
    {
      "id": "1",
      "name": "Golden Dragon",
      "address": "123 Main Street, San Francisco, CA 94102",
      "cuisine": "Chinese",
      "rating": 4.5,
      "priceRange": "$$",
      "openingHours": "11:00",
      "closingHours": "22:00",
      "latitude": 37.7849,
      "longitude": -122.4094,
      "phone": "(415) 555-0101",
      "description": "Authentic Cantonese cuisine",
      "distance": 0.5
    }
  ],
  "searchLocation": {
    "latitude": 37.7749,
    "longitude": -122.4194,
    "address": "San Francisco"
  }
}
```

## 🤖 AI-Assisted Development

This project is designed to be enhanced using AI coding assistants such as Claude Code and agentic IDEs such as Cursor or Windsurf.

We will focus on using Claude Code in this workshop so use whichever IDE you're comfortable with to review/edit files manually. 

## 📄 License

MIT License - feel free to use this project for learning and workshops.

## 🙏 Acknowledgments

Built for the "Becoming a 100x Dev" Workshop at IPNSummit 2026. Happy coding! 🎉
